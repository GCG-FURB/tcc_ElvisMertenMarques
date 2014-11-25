#import "TGInitialListViewController.h"

@interface TGInitialListViewController ()

@end

@implementation TGInitialListViewController

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//
//    }
//    return self;
//}

- (id)init
{
    self = [super init];
    if (self) {
        shoudLoadPatients = YES;
        [self initObjects];
    }
    return self;
}

//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//}

- (void)initObjects
{
    if (shoudLoadPatients) {
        [self loadPatients];        
    } else {        
        [self loadPlans];
    }
    
    groupPlanController = [[TGGroupPlanController alloc]init];
}

- (void)loadGroupPlans
{
    switch ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type]) {
        case 0:
            groupPlanArray = [groupPlanController loadGroupPlansForSpecificUserWithID:[[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID]];
            break;
        case 1:
            groupPlanArray = [groupPlanController loadGroupPlansForSpecificUserWithID:[[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientServerID]];
            break;
        case 2:
            groupPlanArray = [groupPlanController loadGroupPlansForSpecificUserWithID:[[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientTutorID]];
            break;
    }
}

- (void)loadPlans
{    
    planController = [[TGPlanController alloc]init];
    
    switch ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type]) {
        case 0:
            plansArray = [planController loadPlansFromCoreDataForSpecificTutor:[[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientTutorID]];
            break;
        case 1:
            plansArray = [planController loadPlansFromCoreDataForSpecificPatient:[[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientServerID]];
            break;
        case 2:
            plansArray = [planController loadPlansFromCoreDataForSpecificTutor:[[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientServerID]];
            break;
    }
}

- (void)loadPlansForSelectedGroupPlan:(GroupPlan*)selectedGroupPlan
{
    shoudLoadPatients = NO;
    plansLoaded = YES;
    groupPlansLoaded = NO;
    
    switch ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type]) {
        case 0:
            plansArray = [groupPlanController loadPlansForGroupPlan:selectedGroupPlan andForSpecificTutor:[[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientTutorID]];
            break;
        case 1:
            plansArray = [groupPlanController loadPlansForGroupPlan:selectedGroupPlan andForSpecificTutor:[[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientTutorID]];
            break;
        case 2:
            plansArray = [groupPlanController loadPlansForGroupPlan:selectedGroupPlan andForSpecificTutor:[[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientServerID]];
            break;
    }
    
    [[self tableView]reloadData];
}

- (void)loadPatients
{    
    tutorPatientsController = [[TGTutorPatientsController alloc]init];
    switch ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type]) {
        case 0:
        case 1:
            patientsArray = [tutorPatientsController loadRelationshipsBetweenTutorAndPatientFromCoreData];
            break;
        case 2:
            patientsArray = [tutorPatientsController loadRelationshipsBetweenSpecialistAndPatientFromCoreData];
            break;
    }
}

//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 612, 44)];
    
    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 512, 44)];
    [view addSubview:toolbar];
    
    if (plansLoaded || tutorsLoaded || groupPlansLoaded) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]init];
        [backButton setStyle:UIBarButtonItemStyleBordered];
        [backButton setTitle:NSLocalizedString(@"labelVoltar", nil)];
        [backButton setAction:@selector(backToPatientsList)];
        [backButton setTarget:self];
        [toolbar setItems:@[backButton]];        
    }
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 512, 21)];
    [titleLabel setTextColor:[UIColor colorWithRed:108.0/255.0 green:179.0/255.0 blue:246.0/255.0 alpha:1]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [view addSubview:titleLabel];
    
    if (shoudLoadPatients) {
        switch ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type]) {
            case 0:
                [titleLabel setText:NSLocalizedString(@"labelTutors", nil)];
                break;
            case 1:
            case 2:
                [titleLabel setText:NSLocalizedString(@"labelPatients", nil)];
                break;
        }        
    } else if (plansLoaded) {
        switch ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type]) {
            case 0:
                [titleLabel setText:[NSString stringWithFormat:NSLocalizedString(@"labelTutorPlans", nil), [[patientsArray objectAtIndex:selectedIndex]patientName]]];
                break;
            case 1:
                [titleLabel setText:[NSString stringWithFormat:NSLocalizedString(@"labelPatientsPlans", nil), [[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientName]]];
                break;
            case 2:
                if (plansLoaded) {
                    [titleLabel setText:[NSString stringWithFormat:NSLocalizedString(@"labelTutorPlans", nil), [[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientName]]];                    
                } else {
                    [titleLabel setText:[NSString stringWithFormat:NSLocalizedString(@"labelPatientTutors", nil), [[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientName]]];
                }
                break;
        }
    } else if (groupPlansLoaded) {        
        switch ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type]) {
            case 0:
                [titleLabel setText:[NSString stringWithFormat:NSLocalizedString(@"labelTutorGroupPlans", nil), [[patientsArray objectAtIndex:selectedIndex]patientName]]];
                break;
            case 1:
                [titleLabel setText:[NSString stringWithFormat:NSLocalizedString(@"labelPatientsGroupPlans", nil), [[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientName]]];
                break;
            case 2:
                if (plansLoaded) {
                    [titleLabel setText:[NSString stringWithFormat:NSLocalizedString(@"labelTutorGroupPlans", nil), [[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientName]]];
                } else {
                    [titleLabel setText:[NSString stringWithFormat:NSLocalizedString(@"labelPatientsGroupPlans", nil), [[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientName]]];
                }
                break;
        }
    }
    return view;
}

- (void)backToPatientsList
{
    plansLoaded = NO;
    shoudLoadPatients = YES;
    [self loadPatients];
    [[self tableView]reloadData];
    
    [[TGCurrentUserManager sharedCurrentUserManager]setSelectedTutorPatient:nil];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"didSelectTutorFromList" object:[[TGCurrentUserManager sharedCurrentUserManager]currentUser]];    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (shoudLoadPatients) {
        return [patientsArray count];
    } else if (plansLoaded) {
        return [plansArray count];
    } else if (tutorsLoaded) {
        return [tutorsArray count];
    } else if (groupPlansLoaded) {
        return [groupPlanArray count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (shoudLoadPatients) {
        [[cell textLabel]setText:[[patientsArray objectAtIndex:[indexPath row]]patientName]];
    } else if (plansLoaded) {
        [[cell textLabel]setText:[[plansArray objectAtIndex:[indexPath row]]name]];
    } else if (tutorsLoaded) {
        [[cell textLabel]setText:[[tutorsArray objectAtIndex:[indexPath row]]patientName]];
    } else if (groupPlansLoaded) {
        [[cell textLabel]setText:[[groupPlanArray objectAtIndex:[indexPath row]]name]];
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[TGCurrentUserManager sharedCurrentUserManager]setSelectedTutorPatient:[patientsArray objectAtIndex:selectedIndex]];
    shoudLoadPatients = NO;
    groupPlansLoaded = YES;
    [self loadGroupPlans];
    [[self tableView]reloadData];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"didSelectTutorFromList" object:[patientsArray objectAtIndex:selectedIndex]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (shoudLoadPatients) {
        selectedIndex = (int)[indexPath row];
        
        switch ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type]) {
            case 0:
                if ([[patientsArray objectAtIndex:selectedIndex]patientServerID] == [[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID]) {
                    
                    shoudLoadPatients = NO;
                    groupPlansLoaded = YES;
                    [[TGCurrentUserManager sharedCurrentUserManager]setSelectedTutorPatient:[patientsArray objectAtIndex:[indexPath row]]];
                    [self loadGroupPlans];
                    [[self tableView]reloadData];
                    
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"didSelectTutorFromList" object:[patientsArray objectAtIndex:selectedIndex]];
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"alertCaption", nil) message:NSLocalizedString(@"messageTutorIDForPlanAccess", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView setAlertViewStyle:UIAlertViewStyleSecureTextInput];
                    [alertView show];
                }
                break;
            case 1:
                [[TGCurrentUserManager sharedCurrentUserManager]setSelectedTutorPatient:[patientsArray objectAtIndex:[indexPath row]]];
                shoudLoadPatients = NO;
                groupPlansLoaded = YES;
                [self loadGroupPlans];
                [[self tableView]reloadData];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"didSelectTutorFromList" object:[patientsArray objectAtIndex:selectedIndex]];
                break;
            case 2:
                [self showPatientTutorsAfterSelectionForIndexPath:(int)[indexPath row]];
                break;
        }
    } else if (plansLoaded) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"didSelectPlan" object:[plansArray objectAtIndex:[indexPath row]]];
    } else if (tutorsLoaded) {
        [[TGCurrentUserManager sharedCurrentUserManager]setSelectedTutorPatient:[tutorsArray objectAtIndex:[indexPath row]]];
        shoudLoadPatients = NO;
        tutorsLoaded = NO;
        groupPlansLoaded = YES;
        [self loadGroupPlans];
        [[self tableView]reloadData];
        
        //[self showPlansAfterSelectionForIndexPath:[indexPath row]];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"didSelectTutorFromList" object:[tutorsArray objectAtIndex:[indexPath row]]];
    } else if (groupPlansLoaded) {
        [self loadPlansForSelectedGroupPlan:[groupPlanArray objectAtIndex:[indexPath row]]];
    }
}

- (void)showPlansAfterSelectionForIndexPath:(int)indexPath
{
    if (tutorsLoaded) {
        [[TGCurrentUserManager sharedCurrentUserManager]setSelectedTutorPatient:[tutorsArray objectAtIndex:indexPath]];
        shoudLoadPatients = NO;
        plansLoaded = YES;
        [self loadPlans];
        [[self tableView]reloadData];
    } else {
        [[TGCurrentUserManager sharedCurrentUserManager]setSelectedTutorPatient:[patientsArray objectAtIndex:indexPath]];
        shoudLoadPatients = NO;
        plansLoaded = YES;
        [self loadPlans];
        [[self tableView]reloadData];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"didSelectTutorFromList" object:[patientsArray objectAtIndex:selectedIndex]];
    }
}

- (void)showPatientTutorsAfterSelectionForIndexPath:(int)indexPath
{
    shoudLoadPatients = NO;
    plansLoaded = NO;
    tutorsLoaded = YES;
    [[TGCurrentUserManager sharedCurrentUserManager]setSelectedTutorPatient:[patientsArray objectAtIndex:indexPath]];
    
    [self loadTutorsWithPatientID:[[patientsArray objectAtIndex:indexPath]patientServerID]];
    [[self tableView]reloadData];
}

- (void)loadTutorsWithPatientID:(int)patientID
{
    tutorsArray = [tutorPatientsController loadRelationshipsBetweenTutorAndPatientFromCoreDataWithPatientID:patientID];
}

@end