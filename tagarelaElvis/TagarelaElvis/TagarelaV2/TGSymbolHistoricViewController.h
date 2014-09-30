#import "TGSymbolHistoricController.h"
#import "SymbolHistoric.h"
#import "TGSymbolHistoricCell.h"

@interface TGSymbolHistoricViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    TGSymbolHistoricController *symbolHistoricController;
    NSArray *symbolHistoricArray;
    NSDateFormatter *dateFormatter;
}

@property (weak, nonatomic) IBOutlet UITableView *symbolHistoricTableView;
@property (weak, nonatomic) IBOutlet UIToolbar *symbolHistoricToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;
- (IBAction)closeButton:(id)sender;

@end