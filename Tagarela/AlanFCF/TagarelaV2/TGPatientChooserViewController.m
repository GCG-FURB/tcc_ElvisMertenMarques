#import "TGPatientChooserViewController.h"

@interface TGPatientChooserViewController ()

@end

@implementation TGPatientChooserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self customizeViewStyle];
    
    [self internationalizeView];
    
    [self initAndConfigureObjects];
}

- (void)initAndConfigureObjects
{
    tutorPatientsController = [[TGTutorPatientsController alloc]init];
    
    [[self patientID]becomeFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{    
    if (buttonIndex == 0) {
        [[self infoLabel]setHidden:NO];
        [[self selectedPatientImage]setImage:nil];
        [[self selectedPatientName]setText:@""];
        [[self selectedPatientName]setHidden:YES];
    } else {
        switch ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type]) {
            case 0:
            case 1:
                [tutorPatientsController createRelationshipInBackendBetweenTutorAndPatientWithSuccessHandler:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"alertCaption", nil) message:NSLocalizedString(@"successMessageTutorPatientRelationship", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"okCaption", nil) otherButtonTitles:nil];
                        [alertView show];
                    });
                } failHandler:^(NSString *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"alertCaption", nil) message:error delegate:nil cancelButtonTitle:NSLocalizedString(@"okCaption", nil) otherButtonTitles:nil];
                        [alertView show];
                    });
                }];
                break;
            case 2:
                [tutorPatientsController createRelationshipInBackendBetweenSpecialistAndPatientWithSuccessHandler:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"alertCaption", nil) message:NSLocalizedString(@"successMessageSpecialistPatientRelationship", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"okCaption", nil) otherButtonTitles:nil];
                        [alertView show];
                    });
                } failHandler:^(NSString *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"alertCaption", nil) message:error delegate:nil cancelButtonTitle:NSLocalizedString(@"okCaption", nil) otherButtonTitles:nil];
                        [alertView show];
                    });
                }];
                break;
        }
    }
}

- (IBAction)closeScreen:(id)sender
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"didClosePatientChooserScreen" object:nil];
    
    [[TGCurrentUserManager sharedCurrentUserManager]setLastSync:nil];
    syncUserContentController = [[TGSyncUserContentController alloc]init];
    [syncUserContentController syncAllData];    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[KGModal sharedInstance]hideAnimated:YES];
    });
}

- (IBAction)addPatient:(id)sender
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"waitFetchingTutorData", nil)];
    
    [self addPatient];
}

- (void)addPatient
{
    switch ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type]) {
        case 0: {
            [tutorPatientsController fetchTutorDataWithTutorEmail:[[self patientID]text] successHandler:^(TGSelectedTutor *selectedTutor) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                });
                
                [self handleSelectedTutor:selectedTutor];
            } failHandler:^(NSString *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"alertCaption", nil) message:error delegate:self cancelButtonTitle:NSLocalizedString(@"okCaption", nil) otherButtonTitles:nil];
                    [alertView show];
                    [SVProgressHUD dismiss];
                });
            }];
        }
        break;
        case 1:
        case 2:
            [tutorPatientsController fetchPatientDataWithPatientEmail:[[self patientID]text] successHandler:^(TGSelectedPatient *selectedPatient) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                });
                
                [self handleSelectedPatient:selectedPatient];
            } failHandler:^(NSString *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"alertCaption", nil) message:error delegate:self cancelButtonTitle:NSLocalizedString(@"okCaption", nil) otherButtonTitles:nil];
                    [alertView show];
                    [SVProgressHUD dismiss];
                });
            }];
            break;
    }
}

- (void)handleSelectedTutor:(TGSelectedTutor *)selectedTutor
{
    UIAlertView *alertView;
    
    [[self infoLabel]setHidden:YES];
    [[self selectedPatientImage]setImage:[UIImage imageWithData:[selectedTutor selectedTutorImage]]];
    [[self selectedPatientName]setText:[selectedTutor selectedTutorName]];
    [[self selectedPatientName]setHidden:NO];
    
    alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"alertCaption", nil) message:NSLocalizedString(@"tutorPatientQuestion2", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"noOption", nil) otherButtonTitles:NSLocalizedString(@"yesOption", nil), nil];
    [alertView show];
}

- (void)handleSelectedPatient:(TGSelectedPatient *)selectedPatient
{
    UIAlertView *alertView;
    
    [[self infoLabel]setHidden:YES];
    [[self selectedPatientImage]setImage:[UIImage imageWithData:[selectedPatient selectedPatientImage]]];
    [[self selectedPatientName]setText:[selectedPatient selectedPatientName]];
    [[self selectedPatientName]setHidden:NO];
    
    alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"alertCaption", nil) message:NSLocalizedString(@"tutorPatientQuestion", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"noOption", nil) otherButtonTitles:NSLocalizedString(@"yesOption", nil), nil];
    [alertView show];
}

- (void)customizeViewStyle
{
    UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG-pattern.png"]];
    [[self view]setBackgroundColor:color];
    [[self selectedPatientName]setHidden:YES];
}

- (void)internationalizeView
{
    switch ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type]) {
        case 0:
            [[self infoLabel]setText:NSLocalizedString(@"infoLabelTutor", @"")];
            [[self patientID]setPlaceholder:NSLocalizedString(@"textfieldIDPlaceholderTutor", nil)];
            break;
        case 1:
        case 2:
            [[self infoLabel]setText:NSLocalizedString(@"infoLabelPatient", @"")];
            [[self patientID]setPlaceholder:NSLocalizedString(@"textfieldIDPlaceholderPatient", nil)];
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end