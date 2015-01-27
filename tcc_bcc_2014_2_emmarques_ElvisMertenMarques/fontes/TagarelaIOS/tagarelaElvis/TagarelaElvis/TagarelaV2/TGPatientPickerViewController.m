#import "TGPatientPickerViewController.h"

@interface TGPatientPickerViewController ()

@end

@implementation TGPatientPickerViewController

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
    
    [self initAndConfigureObjects];
}

- (void)initAndConfigureObjects
{
    tutorPatientsController = [[TGTutorPatientsController alloc]init];
    
    tutorPatients = [tutorPatientsController loadRelationshipsBetweenTutorAndPatientFromCoreData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)cancelSelection:(id)sender
{
    [[KGModal sharedInstance]hideAnimated:YES];    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tutorPatients count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PatientCell"];
    
    [[cell textLabel]setText:[[tutorPatients objectAtIndex:[indexPath row]]patientName]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[TGCurrentUserManager sharedCurrentUserManager]setSelectedTutorPatient:[tutorPatients objectAtIndex:[indexPath row]]];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"didSelectPatient" object:nil];
    
    [[KGModal sharedInstance]hideAnimated:YES];
}

- (void)customizeViewStyle
{
    UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG-pattern.png"]];
    [[self view]setBackgroundColor:color];
}

@end