#import "TGUserHistoricViewController.h"

@interface TGUserHistoricViewController ()

@end

@implementation TGUserHistoricViewController

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
    
    [self initObjects];
    
    [self customizeViewStyle];
    
    [[self userHistoricTextView]becomeFirstResponder];
    
    [self loadObservations];
    
    lenghtOfLoadedText = (int)[[[[self userHistoricTextView]text]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length];
}

- (void)initObjects
{
    userHistoricController = [[TGUserHistoricController alloc]init];    
    dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
    
    //se o usuário for um especialista, não deixar ele editar as observações de outros tutores
    if ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type] == 2) {
        if ([[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]) {
            if ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID] != [[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientServerID]) {
                [[self userHistoricTextView]setEditable:NO];
            }
        }
    }
}

- (void)loadObservations
{        
    NSArray *observationsArray;
    
    switch ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type]) {
        case 0:
            if ([[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]) {
                observationsArray = [userHistoricController loadObservationsFromCoreDataForPatient:[[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID] withTutor:[[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientTutorID]];
            } else {
                observationsArray = [userHistoricController loadAllObservationsFromCoreDataForUserWithID:[[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID]];
            }
            break;
        case 1:
            observationsArray = [userHistoricController loadObservationsFromCoreDataForPatient:[[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientServerID] withTutor:[[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID]];
            break;
        case 2:
            observationsArray = [userHistoricController loadObservationsFromCoreDataForPatient:[[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientTutorID] withTutor:[[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientServerID]];
            break;
    }
    
    for (int i = 0; i < [observationsArray count]; i++) {
        NSString *textToAppend = [[observationsArray objectAtIndex:i]observation];
        
        [dateFormat setDateFormat:@"H:mm"];
        NSString *hour = [dateFormat stringFromDate:[[observationsArray objectAtIndex:i]date]];
        [dateFormat setDateFormat:@"dd/MM/yy"];
        NSString *day = [dateFormat stringFromDate:[[observationsArray objectAtIndex:i]date]];
        
        [[self userHistoricTextView]setText:[[[self userHistoricTextView]text]stringByAppendingString:[NSString stringWithFormat:@"%@ horas do dia %@ \n", hour, day]]];
        [[self userHistoricTextView]setText:[[[self userHistoricTextView]text]stringByAppendingString:[NSString stringWithFormat:@"%@ \n", textToAppend]]];
    }    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)closeUserHistoric:(id)sender
{    
    NSString *textToSave = [[[[self userHistoricTextView]text]substringFromIndex:lenghtOfLoadedText]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [userHistoricController createObservationInDeviceWithString:textToSave successHandler:^{
        NSLog(@"sucesso");
    } failHandler:^(NSString *error){
        NSLog(@"Erro ao salvar");
    }];
    
    [[KGModal sharedInstance]hideAnimated:YES];
}

- (void)customizeViewStyle
{
    [[self userHistoricTextView]setFont:[UIFont fontWithName:@"HelveticaNeue" size:20.0]];
    [[self userHistoricTextView]setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"notes_texture_1"]]];
    
    UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG-pattern.png"]];
    [[self view]setBackgroundColor:color];
}

@end