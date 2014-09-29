#import "Category.h"
#import "TGCategoryController.h"
#import "KGModal.h"

@interface TGCategoriesListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *categoriesArray;
    TGCategoryController *categoryController;
}

@property (weak, nonatomic) IBOutlet UITableView *categoriesTableView;
@property (weak, nonatomic) IBOutlet UIToolbar *categoriesListToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelSelectionButton;

- (IBAction)cancelSelection:(id)sender;

@end