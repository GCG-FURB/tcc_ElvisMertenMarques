#import <UIKit/UIKit.h>
#import "TGAlbumPhotoCell.h"
#import "TGAlbunsListViewController.h"

@interface TGAlbumContentsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
{
    NSMutableArray *assets;
    int currentIndex;
}

@property (nonatomic, retain) ALAssetsGroup *assetsGroup;
@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) IBOutlet UIBarButtonItem *backToAlbunsList;

- (IBAction)backToAlbunsList:(id)sender;

@end