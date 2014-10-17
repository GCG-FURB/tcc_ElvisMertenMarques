#import "TGGroupPlanListViewController.h"

@interface TGGroupPlanListViewController ()

@end

@implementation TGGroupPlanListViewController

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
    
    currentUserID = 0;
    
    switch ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type]) {
        case 0:
            currentUserID = [[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID];
            break;
        case 1:
            currentUserID = [[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientServerID];
            break;
        case 2:
            currentUserID = [[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientTutorID];
            break;
    }
    
    groupPlanController = [[TGGroupPlanController alloc]init];
    groupPlanArray = [groupPlanController loadGroupPlansForSpecificUserWithID:currentUserID];
        NSMutableArray* array =[NSMutableArray new];
        for (GroupPlan* groupPlan in groupPlanArray) {
            if (_type==groupPlan.type) {
                [array addObject:groupPlan];
            }
        }
    groupPlanArray = array;
    
    [[self groupPlanTableView]reloadData];
    
    [self customizeViewStyle];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [groupPlanArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell"];
    
    GroupPlan *g = [groupPlanArray objectAtIndex:[indexPath row]];
    
    [[cell textLabel]setText:[g name]];
    
    return cell;
}

- (void)customizeViewStyle
{
    UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG-pattern.png"]];
    [[self view]setBackgroundColor:color];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"didSelectGroupPlan" object:[groupPlanArray objectAtIndex:[indexPath row]]];
    
    [[KGModal sharedInstance]hideAnimated:YES];
}

- (IBAction)cancelSelection:(id)sender
{
    [[KGModal sharedInstance]hideAnimated:YES];
}

- (IBAction)createNewGroupPlan:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Criar novo grupo" message:@"Escreva o nome do grupo" delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Criar", nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [groupPlanController createGroupPlanWithName:[[alertView textFieldAtIndex:0]text] andUserID:currentUserID withType:_type successHandler:^() {
        groupPlanArray = [groupPlanController loadGroupPlansForSpecificUserWithID:currentUserID];
        NSMutableArray *array = [NSMutableArray new];
        for (GroupPlan* groupPlan in groupPlanArray) {
            if (_type==groupPlan.type) {
                [array addObject:groupPlan];
            }
        }
        groupPlanArray = array;
        [[self groupPlanTableView]reloadData];
        
    } failHandler:^(NSString *error) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Atencão" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end