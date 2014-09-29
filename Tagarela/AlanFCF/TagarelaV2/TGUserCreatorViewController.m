#import "TGUserCreatorViewController.h"

@interface TGUserCreatorViewController ()

@end

@implementation TGUserCreatorViewController

@synthesize popover;

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
    
    [self customizeViewStyle];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didPickedImage:) name:@"didPickedImage" object:nil];
}

- (void)didPickedImage:(NSNotification*)notification
{
    [[self userPicture]setImage:[notification object]];
    hasImage = YES;
    [popover dismissPopoverAnimated:YES];
}

- (void)initObjects
{
    userCreatorController = [[TGUserController alloc]init];    
    imagePicker = [[TGImagePickerViewController alloc]init];
    [imagePicker setDelegate:self];
    creationCanceled = NO;
    hasImage = NO;
}

- (void)customizeViewStyle
{
    UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG-pattern.png"]];
    [[self view]setBackgroundColor:color];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if ([[touch view]isKindOfClass:[UIImageView class]]) {
        [self showActionSheetWithOptions];
    }
}

/**
 * Método responsável por mostrar a UIActionSheet com as opções de escolha para a foto do paciente.
**/

- (void)showActionSheetWithOptions
{
    UIActionSheet *action = [[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"photoChooserActionSheetTitle", nil)
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"photoChooserPhotoGalleryOption", nil), NSLocalizedString(@"photoChooserTakePictureOption", nil), nil];
    [action setActionSheetStyle:UIActionSheetStyleBlackOpaque];    
    [action setDelegate:self];
    [action showInView:[self view]];
    [[self view]endEditing:YES];        
}

/**
 * Método chamado quando o usuário seleciona uma opção no UIActionSheet.
**/

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self chooseImageFromLibrary];
            break;
        case 1:
            [self takePatientPicture];
            break;
    }
}

/**
 * Método responsável por mostrar ao usuário a tela do rolo de fotos do iPad.
**/

- (void)chooseImageFromLibrary
{
    TGAlbunsListViewController *albunsListViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil]instantiateViewControllerWithIdentifier:@"TGAlbunsListViewController"];
    
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:albunsListViewController];
    
    popover = [[UIPopoverController alloc]initWithContentViewController:navigationController];
    [popover presentPopoverFromRect:CGRectMake(80, 100, 100, 100) inView:[self view] permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];    
}

/**
 * Método responsável por mostrar ao usuário a tela de captura de imagens padrão do iOS.
**/

- (void)takePatientPicture
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [self presentViewController:imagePicker animated:YES completion:nil];
    } else {
        [self chooseImageFromLibrary];
    }
}

/**
 * Método do delegate da classe UIImagePickerController, chamado quando uma imagem é selecionada.
**/

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([picker sourceType] == UIImagePickerControllerSourceTypeCamera) {
        UIImage *imageFromCamera = [[info objectForKey:UIImagePickerControllerOriginalImage]scaleToSize:CGSizeMake(500, 500)];
        [[self userPicture]setImage:imageFromCamera];
        hasImage = YES;
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [popover dismissPopoverAnimated:YES];
        hasImage = YES;
        [[self userPicture]setImage:[[info objectForKey:UIImagePickerControllerOriginalImage]scaleToSize:CGSizeMake(250, 250)]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)cancelCreation:(id)sender
{
    creationCanceled = YES;
    [[KGModal sharedInstance]hideAnimated:YES];
}

- (IBAction)finishCreation:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showWithStatus:NSLocalizedString(@"waitMessageCreation", nil)];
    });
    
    __block UIAlertView *alertView;
    
    if ([self checkFields]) {
        [userCreatorController setIsNewUser:YES];        
        [[TGCurrentUserManager sharedCurrentUserManager]setIsNewUser:YES];
        
        [userCreatorController createUserWithName:[[self userName]text]
                                      andPassword:[[self userPassword]text]
                                         andEmail:[[self userEmail]text]
                                          andType:[self userType]
                                       andPicture:[[self userPicture]image]
                                   successHandler:^ {
                                       alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"alertCaption", nil) message:NSLocalizedString(@"successMessageUserCreation", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                       [alertView setTag:999];
                                       
                                       dispatch_async(dispatch_get_main_queue(),^{
                                           [SVProgressHUD dismiss];
                                           [alertView show];
                                       });
                                   } failHandler:^(NSString *error) {
                                       alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"alertCaption", nil) message:error delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                       [alertView setTag:888];
                                       
                                       dispatch_async(dispatch_get_main_queue(),^{
                                           [SVProgressHUD dismiss];
                                           [alertView show];
                                       });
                                   }];
    }
}

- (BOOL)checkFields
{
    NSMutableString *message = [[NSMutableString alloc]initWithCapacity:0];
    
    for (int i = 0; i < [[[self view]subviews]count]; i++) {
        UIView *view = [[[self view]subviews]objectAtIndex:i];
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField*)view;
            if ([[textField text]isEqualToString:@""]) {
                if ([textField tag] != 1) {
                    [message appendString:[NSString stringWithFormat:@"%@ \n", [textField placeholder]]];
                }
            }
        }
    }
    
    if ([message length] > 0 || !hasImage) {
        NSString *title;
        
        if ([message length] > 0) {
            title = NSLocalizedString(@"missingFieldsMessageCreation", nil);
        } else {
            title = NSLocalizedString(@"alertCaption", nil);
            message = [NSMutableString stringWithFormat:NSLocalizedString(@"missingPictureMessageUserCreation", nil)];
        }
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"okCaption", nil) otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView tag] == 999) {
        [[KGModal sharedInstance]hideAnimated:YES];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"userCreated" object:nil];        
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (creationCanceled) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"userNotCreated" object:nil];
    }
}

@end