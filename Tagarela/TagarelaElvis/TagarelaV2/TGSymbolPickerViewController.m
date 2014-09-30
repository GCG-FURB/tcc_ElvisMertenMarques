#import "TGSymbolPickerViewController.h"

@interface TGSymbolPickerViewController ()

@end

@implementation TGSymbolPickerViewController

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
}

- (void)initObjects
{
    categoryController = [[TGCategoryController alloc]init];
    symbolController = [[TGSymbolController alloc]init];
    
    categoriesArray = [NSMutableArray arrayWithArray:[categoryController loadCategoriesFromCoreData]];
    
    [self customizeViewStyle];
}

- (void)customizeViewStyle
{
    UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG-pattern.png"]];
    [[self collectionView]setBackgroundColor:color];
    //[[self symbolPickerToolbar]setBackgroundImage:[UIImage imageNamed:@"ipad-menubar-right@2x.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    //[[self backToPreviousScreenButton]setBackgroundImage:[UIImage imageNamed:@"ipad-menubar-button.png"] forState:UIControlStateNormal style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsDefault];
    
    [[self backToPreviousScreenButton]setEnabled:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (didSelectCategory) {
        return [symbolsArray count];
    } else {
        return [categoriesArray count];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGSymbolPickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TGSymbolPickerCell" forIndexPath:indexPath];
    
    if (didSelectCategory) {
        Symbol *symbol = [symbolsArray objectAtIndex:[indexPath row]];
        Category *symbolCategory = (Category*)[[symbolsArray objectAtIndex:[indexPath row]]category];
        
        [[[cell imageView]layer]setBorderWidth:10.0];
        [[cell imageView]setImage:[UIImage imageWithData:[symbol picture]]];
        [[[cell imageView]layer]setBorderColor:[[UIColor colorWithRed:[symbolCategory red]/255.0f green:[symbolCategory green]/255.0f blue:[symbolCategory blue]/255.0f alpha:1]CGColor]];
        [[cell label]setHidden:YES];
    } else {
        Category *category = [categoriesArray objectAtIndex:[indexPath row]];        
        [[cell imageView]setImage:nil];
        [[[cell imageView]layer]setBorderWidth:10.0];
        [[[cell imageView]layer]setBorderColor:[[UIColor colorWithRed:[category red]/255.0f green:[category green]/255.0f blue:[category blue]/255.0f alpha:1]CGColor]];
        [[cell label]setText:[category name]];
        [[cell label]setHidden:NO];
    }
    
    return cell;        
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(150, 150);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (didSelectCategory) {
        Symbol *symbol = [symbolsArray objectAtIndex:[indexPath row]];
        TGSymbolPickerCell *cell = (TGSymbolPickerCell*)[collectionView cellForItemAtIndexPath:indexPath];
        [[cell imageView]setAlpha:0.5];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"didSelectSymbol" object:symbol];
        [[KGModal sharedInstance]hideAnimated:YES];
    } else {
        didSelectCategory = YES;
        Category *category = [categoriesArray objectAtIndex:[indexPath row]];
        symbolsArray = [NSMutableArray arrayWithArray:[symbolController loadSymbolsFromCoreDataWithCategory:category]];
        [categoriesArray removeAllObjects];
        [[self collectionView]reloadData];
        [[self backToPreviousScreenButton]setEnabled:YES];
        [[self symbolPickerToolbarLabel]setText:[category name]];
    }
}

- (IBAction)backToPreviousScreen:(id)sender
{
    categoriesArray = [NSMutableArray arrayWithArray:[categoryController loadCategoriesFromCoreData]];
    didSelectCategory = NO;
    [symbolsArray removeAllObjects];
    [[self collectionView]reloadData];
    [[self backToPreviousScreenButton]setEnabled:NO];
    [[self symbolPickerToolbarLabel]setText:NSLocalizedString(@"pickCategoryCaption", nil)];
}

@end