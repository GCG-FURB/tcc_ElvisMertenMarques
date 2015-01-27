#import <UIKit/UIKit.h>
#import "TGAlbumContentsViewController.h"

@interface TGAlbunsListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    ALAssetsLibrary *assetsLibrary;
    NSMutableArray *groups;
    int selectedIndex;
}

- (IBAction)closeScreen:(id)sender;

@property (nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;

@end