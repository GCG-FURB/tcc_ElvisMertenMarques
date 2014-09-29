#import "TGSymbolController.h"
#import "TGSymbolsListCell.h"
#import "Category.h"

@interface TGSymbolsListViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate>
{
    NSArray *symbolsArray;
    NSArray *searchResult;
    TGSymbolController *symbolCreatorController;
    BOOL searchIsOn;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIToolbar *symbolListToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeScreenButton;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end