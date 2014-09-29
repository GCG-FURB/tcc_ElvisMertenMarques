#import "TGSymbolsListViewController.h"

@interface TGSymbolsListViewController ()

@end

@implementation TGSymbolsListViewController

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
    
    [self initAndConfigureObjects];
    
    [self loadSymbols];
    
    [self customizeViewStyle];
}

- (void)initAndConfigureObjects
{
    symbolCreatorController = [[TGSymbolController alloc]init];
    
    searchIsOn = NO;
}

- (void)loadSymbols
{
    symbolsArray = [symbolCreatorController loadSymbolsFromCoreData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)customizeViewStyle
{
    UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG-pattern.png"]];
    [[self collectionView]setBackgroundColor:color];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (searchIsOn) {
        return [searchResult count];
    } else {
        return [symbolsArray count];        
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""]) {
        searchIsOn = NO;
        [[self collectionView]reloadData];
    } else {
        searchIsOn = YES;
        searchResult = [symbolCreatorController loadSymbolsWithName:searchText];
        [[self collectionView]reloadData];
    }        
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGSymbolsListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TGSymbolsListCell" forIndexPath:indexPath];
    
    Symbol *symbol;
    Category *symbolCategory;
    
    if (searchIsOn) {
        symbol = [searchResult objectAtIndex:[indexPath row]];
        symbolCategory = (Category*)[[searchResult objectAtIndex:[indexPath row]]category];
    } else {
        symbol = [symbolsArray objectAtIndex:[indexPath row]];
        symbolCategory = (Category*)[[symbolsArray objectAtIndex:[indexPath row]]category];
    }
    
    [[[cell imageView]layer]setBorderWidth:10.0];
    [[cell imageView]setImage:[UIImage imageWithData:[symbol picture]]];
    [[[cell imageView]layer]setBorderColor:[[UIColor colorWithRed:[symbolCategory red]/255.0f green:[symbolCategory green]/255.0f blue:[symbolCategory blue]/255.0f alpha:1]CGColor]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(200, 200);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (searchIsOn) {        
        [self setAudioPlayer:[[AVAudioPlayer alloc]initWithData:[[searchResult objectAtIndex:[indexPath row]]sound] error:nil]];
    } else {
        [self setAudioPlayer:[[AVAudioPlayer alloc]initWithData:[[symbolsArray objectAtIndex:[indexPath row]]sound] error:nil]];
    }
    
    [[self audioPlayer]setNumberOfLoops:0];
    [[self audioPlayer]prepareToPlay];
    [[self audioPlayer]play];    
}

@end