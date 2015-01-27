#import "TGSymbolHistoricViewController.h"

@interface TGSymbolHistoricViewController ()

@end

@implementation TGSymbolHistoricViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)customizeViewStyle
{
    UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG-pattern.png"]];
    [[self symbolHistoricTableView]setBackgroundColor:color];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    symbolHistoricController = [[TGSymbolHistoricController alloc]init];
    
    switch ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type]) {
        case 0:
            if ([[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]) {
                symbolHistoricArray = [symbolHistoricController loadSymbolHistoricFromCoreDataForPatient:[[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID] withTutor:[[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientServerID]];
            } else {
                symbolHistoricArray = [symbolHistoricController loadAllSymbolHistoricsFromCoreDataForUserWithID:[[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID]];
            }
            break;
        case 1:
            symbolHistoricArray = [symbolHistoricController loadSymbolHistoricFromCoreDataForPatient:[[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientServerID] withTutor:[[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID]];
            break;
        case 2:
            if ([[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]) {
                if ([[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientTutorID] == [[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID]) {                    
                    symbolHistoricArray = [symbolHistoricController loadAllSymbolHistoricsFromCoreDataForUserWithID:[[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientServerID]];
                } else {
                    symbolHistoricArray = [symbolHistoricController loadSymbolHistoricFromCoreDataForPatient:[[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientTutorID] withTutor:[[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientServerID]];
                }
            }
            break;
    }
    
    dateFormatter = [[NSDateFormatter alloc]init];
    
    [self customizeViewStyle];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (double)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [symbolHistoricArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGSymbolHistoricCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TGSymbolHistoricCell"];
    
    SymbolHistoric *symbolHistoric = [symbolHistoricArray objectAtIndex:[indexPath row]];
    
    [dateFormatter setDateFormat:@"H:mm"];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *hour = [dateFormatter stringFromDate:[symbolHistoric date]];
    [dateFormatter setDateFormat:@"dd/MM/yy"];
    NSString *day = [dateFormatter stringFromDate:[symbolHistoric date]];    
    
    [[cell symbolHistoricDate]setText:[NSString stringWithFormat:NSLocalizedString(@"labelCellSymbolUtilizationDate", nil), hour, day]];
    [[cell symbolImage]setImage:[UIImage imageWithData:[[symbolHistoric symbolHistoric]picture]]];
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
}

- (IBAction)closeButton:(id)sender
{
    [[KGModal sharedInstance]hideAnimated:YES];
}

@end