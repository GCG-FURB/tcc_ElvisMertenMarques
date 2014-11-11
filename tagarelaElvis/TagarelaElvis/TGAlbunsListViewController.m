#import "TGAlbunsListViewController.h"

@interface TGAlbunsListViewController ()

@end

@implementation TGAlbunsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    assetsLibrary = [TGAssetsManager defaultAssetsLibrary];
    
    if (!groups) {
        groups = [[NSMutableArray alloc]init];
    } else {
        [groups removeAllObjects];
    }
    
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {        
        if (group) {
            [groups addObject:group];
        } else {
            [[self tableView]performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    };
            
    NSUInteger groupTypes = ALAssetsGroupSavedPhotos | ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces;
    [assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [groups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }    
    
    ALAssetsGroup *groupForCell = [groups objectAtIndex:indexPath.row];
    CGImageRef posterImageRef = [groupForCell posterImage];
    UIImage *posterImage = [UIImage imageWithCGImage:posterImageRef];
    [[cell imageView]setImage:posterImage];
    [[cell textLabel]setText:[groupForCell valueForProperty:ALAssetsGroupPropertyName]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex = (int)[indexPath row];
    [self performSegueWithIdentifier:@"segueToAlbumContents" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    TGAlbumContentsViewController *albumContentsViewController = [segue destinationViewController];
    [albumContentsViewController setAssetsGroup:[groups objectAtIndex:selectedIndex]];
}

- (IBAction)closeScreen:(id)sender
{
    [[KGModal sharedInstance]hide];
}

@end