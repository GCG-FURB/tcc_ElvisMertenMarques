#import "TGAlbumContentsViewController.h"

@interface TGAlbumContentsViewController ()

@end

@implementation TGAlbumContentsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    assets = [[NSMutableArray alloc]init];
    
    currentIndex = 0;
    
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            [assets addObject:result];
        }
    };
    
    ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
    [[self assetsGroup]setAssetsFilter:onlyPhotosFilter];
    [[self assetsGroup]enumerateAssetsUsingBlock:assetsEnumerationBlock];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didSelectImage:) name:@"didSelectImage" object:nil];
}

- (void)didSelectImage:(NSNotification*)notification
{
    int selectedIndex = [[notification object]intValue];
    
    ALAsset *asset = [assets objectAtIndex:selectedIndex];
    ALAssetRepresentation *representation = [asset defaultRepresentation];
    [representation fullResolutionImage];    
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"didPickedImage" object:[UIImage imageWithCGImage:[representation fullResolutionImage]]];
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
    return [assets count] / 4 + 1;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGAlbumPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TGAlbumPhotoCell" forIndexPath:indexPath];
        
    @try {
        for (int i = 0; i < 4; i++) {            
            ALAsset *asset = [assets objectAtIndex:currentIndex];
            CGImageRef thumbnailImageRef = [asset thumbnail];
            UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
            
            switch (i) {
                case 0:
                    [[cell photo1]setImage:thumbnail];
                    [[cell photo1]setTag:currentIndex];
                    currentIndex++;
                    break;
                case 1:
                    [[cell photo2]setImage:thumbnail];
                    [[cell photo2]setTag:currentIndex];
                    currentIndex++;
                    break;
                case 2:
                    [[cell photo3]setImage:thumbnail];
                    [[cell photo3]setTag:currentIndex];
                    currentIndex++;
                    break;
                case 3:
                    [[cell photo4]setImage:thumbnail];
                    [[cell photo4]setTag:currentIndex];
                    currentIndex++;
                    break;
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", [exception reason]);        
    }
    
    return cell;
}

- (IBAction)backToAlbunsList:(id)sender
{
    [[self navigationController]popViewControllerAnimated:YES];
}

@end