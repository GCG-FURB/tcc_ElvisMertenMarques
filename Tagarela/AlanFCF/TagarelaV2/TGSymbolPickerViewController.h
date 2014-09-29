#import "TGCategoryController.h"
#import "TGSymbolPickerCell.h"
#import "Category.h"
#import "Symbol.h"
#import "TGSymbolController.h"

@interface TGSymbolPickerViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    TGCategoryController *categoryController;
    TGSymbolController *symbolController;
    NSMutableArray *categoriesArray;
    NSMutableArray *symbolsArray;
    BOOL didSelectCategory;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIToolbar *symbolPickerToolbar;
@property (weak, nonatomic) IBOutlet UILabel *symbolPickerToolbarLabel;

- (IBAction)backToPreviousScreen:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backToPreviousScreenButton;

@end