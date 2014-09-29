#import "TGSymbolCreatorViewController.h"

@interface TGSymbolCreatorViewController ()

@end

@implementation TGSymbolCreatorViewController

@synthesize popover;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)initObjects
{
    imagePicker = [[TGImagePickerViewController alloc]init];
    [imagePicker setDelegate:self];
    symbolController = [[TGSymbolController alloc]init];
    recordCountdown = 5;
    hasImage = NO;
    hasSound = NO;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateAudioData:) name:@"AudioRecorded" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didPickedImage:) name:@"didPickedImage" object:nil];
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
    
    if ([message length] > 0 || !hasImage || !hasSound) {
        NSString *title;
        
        if ([message length] > 0) {
            title = NSLocalizedString(@"missingFieldsMessageCreation", nil);
        } else if (!hasImage) {
            title = NSLocalizedString(@"alertCaption", nil);
            message = [NSMutableString stringWithFormat:@"%@", NSLocalizedString(@"missingPictureMessageSymbolCreation", nil)];
        } else if (!hasSound) {
            title = NSLocalizedString(@"alertCaption", nil);
            message = [NSMutableString stringWithFormat:@"%@", NSLocalizedString(@"missingSoundMessageSymbolCreation", nil)];
        }
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if ([[touch view]isKindOfClass:[UIImageView class]]) {
        [self showActionSheetWithOptions];
    }
}

- (void)customizeViewStyle
{
    UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG-pattern.png"]];
    [[self view]setBackgroundColor:color];
    [[[self symbolPicture]layer]setBorderWidth:10.0];
    [[[self symbolPicture]layer]setBorderColor:[[UIColor colorWithRed:[[self selectedCategory]red] / 255.0f green:[[self selectedCategory]green] / 255.0f blue:[[self selectedCategory]blue] / 255.0f alpha:1]CGColor]];
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
        UIImage *imageFromCamera = [[info objectForKey:UIImagePickerControllerOriginalImage]scaleToSize:CGSizeMake(250, 250)];
        [[self symbolPicture]setImage:imageFromCamera];
        hasImage = YES;
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [popover dismissPopoverAnimated:YES];
        [[self symbolPicture]setImage:[[info objectForKey:UIImagePickerControllerOriginalImage]scaleToSize:CGSizeMake(250, 250)]];
        hasImage = YES;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initObjects];
    
    [[self symbolCategory]setText:[[self selectedCategory]name]];
    
    [[self symbolMeaning]becomeFirstResponder];
    
    [[self symbolMeaning]setDelegate:self];
    [[self symbolVideoLink]setDelegate:self];
    
    [self customizeViewStyle];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:[self symbolMeaning]]) {
        [[self symbolVideoLink]becomeFirstResponder];
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)recordSymbolSound:(id)sender
{
    if ([[self recordSoundButton]tag] == 0) {
        [[self recordSoundButton]setTag:1];
        [self startRecording];
        [[self recordSoundButton]setTitle:NSLocalizedString(@"recordSoundButtonCountdowTitle", nil) forState:UIControlStateNormal];
        timerRecordCountdown = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                target: self
                                                              selector:@selector(updateRecordLabel)
                                                              userInfo: nil repeats:YES];
    } else {
        [self stopRecording];
        [[self recordSoundButton]setTag:0];
        [[self recordSoundButton]setTitle:NSLocalizedString(@"recordSoundButtonTitle", nil) forState:UIControlStateNormal];        
    }        
}

- (void)updateRecordLabel
{
    recordCountdown--;
    [[self recordSoundButton]setTitle:[NSString stringWithFormat:@"Gravando 0:0%d", recordCountdown] forState:UIControlStateNormal];
    if (recordCountdown == 0) {
        [timerRecordCountdown invalidate];
        [self stopRecording];
        [[self recordSoundButton]setTag:0];
        [[self recordSoundButton]setTitle:NSLocalizedString(@"recordSoundButtonTitle", nil) forState:UIControlStateNormal];
    }
}

- (void)stopRecording
{
    [symbolController stopRecording];
    recordCountdown = 5;
    [timerRecordCountdown invalidate];    
}

- (void)startRecording
{
    NSString *filePrefix = [[self symbolMeaning]text];
    NSString *recorderFilePath = [NSString stringWithFormat:@"%@/%@.m4a", SOUNDS_FOLDER, filePrefix];
    [symbolController startRecordingWithFilePath:recorderFilePath];
}

- (IBAction)playSymbolSound:(id)sender
{
    NSError *error;
    if (NO) {
        //audioPlayer = [[AVAudioPlayer alloc]initWithData:[selectedSymbol symbolSound] error:nil];
    } else {
        [self setAudioPlayer:[[AVAudioPlayer alloc]initWithData:audioRecorded error:&error]];        
    }
    
    [[self audioPlayer]setNumberOfLoops:0];
    [[self audioPlayer]prepareToPlay];
    [[self audioPlayer]play];
}

- (void)updateAudioData:(NSNotification*)notification
{
    audioRecorded = [notification object];
    hasSound = YES;
}

- (void)didPickedImage:(NSNotification*)notification
{
    [[self symbolPicture]setImage:[notification object]];
    hasImage = YES;
    [popover dismissPopoverAnimated:YES];
}

- (IBAction)cancelCreation:(id)sender
{
    [[KGModal sharedInstance]hideAnimated:YES];
}

- (IBAction)finishCreation:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showWithStatus:NSLocalizedString(@"waitMessageCreation", nil)];
    });
    
    if ([self checkFields]) {
        [symbolController createSymbolWithName:[[self symbolMeaning]text] andPicture:[[self symbolPicture]image] andVideoLink:[[self symbolVideoLink]text] andSound:audioRecorded andCategory:[self selectedCategory] successHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"alertCaption", nil) message:NSLocalizedString(@"successMessageSymbolCreation", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"okCaption", nil) otherButtonTitles:nil];
                [alertView show];
            });
            
            hasImage = NO;
            hasSound = NO;
            symbolCreated = YES;
            
        } failHandler:^(NSString *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"alertCaption", nil) message:error delegate:self cancelButtonTitle:NSLocalizedString(@"okCaption", nil) otherButtonTitles:nil];
                [alertView show];
            });
        }];                
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (symbolCreated) {
        [[self symbolPicture]setImage:[UIImage imageNamed:@"add-imagem-gray"]];
        [[self symbolMeaning]setText:@""];
        [[self symbolVideoLink]setText:@""];
        symbolCreated = NO;
    }
}

@end