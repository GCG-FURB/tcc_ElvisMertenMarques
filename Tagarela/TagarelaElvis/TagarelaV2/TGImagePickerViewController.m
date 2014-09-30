#import "TGImagePickerViewController.h"

@interface TGImagePickerViewController ()

@end

@implementation TGImagePickerViewController

/**
 * Método padrão da classe UIImagePickerController.
 **/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

/**
 * Método padrão da classe UIImagePickerController.
 **/

- (void)viewDidLoad
{
    [super viewDidLoad];
}

/**
 * Método padrão da classe UIImagePickerController.
 **/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end