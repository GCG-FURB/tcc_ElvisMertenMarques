#import "TGCategoriesListViewController.h"

@interface TGCategoriesListViewController ()

@end

@implementation TGCategoriesListViewController

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
    
    categoryController = [[TGCategoryController alloc]init];        
    categoriesArray = [categoryController loadCategoriesFromCoreData];
    
    [[self categoriesTableView]reloadData];
    
    [self customizeViewStyle];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [categoriesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell"];
    
    Category *c = [categoriesArray objectAtIndex:[indexPath row]];
    
    [[cell textLabel]setText:[c name]];
    
    return cell;
}

- (void)customizeViewStyle
{
    UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG-pattern.png"]];
    [[self view]setBackgroundColor:color];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGSymbolCreatorViewController *symbolCreatorViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil]instantiateViewControllerWithIdentifier:@"TGSymbolCreatorViewController"];
    [symbolCreatorViewController setSelectedCategory:[categoriesArray objectAtIndex:[indexPath row]]];
    [[symbolCreatorViewController view]setFrame:CGRectMake(0, 0, 540, 240)];
    [[KGModal sharedInstance]setShowCloseButton:NO];
    [[KGModal sharedInstance]setTapOutsideToDismiss:NO];
    [[KGModal sharedInstance]showWithContentViewController:symbolCreatorViewController andAnimated:YES];
}

- (IBAction)cancelSelection:(id)sender
{
    [[KGModal sharedInstance]hideAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end