#import "TGTutorPatientsController.h"
#import "TGSelectedPatient.h"
#import "TGSyncUserContentController.h"

@interface TGPatientChooserViewController : UIViewController <UIAlertViewDelegate>
{
    TGTutorPatientsController *tutorPatientsController;
    TGSyncUserContentController *syncUserContentController;
}

@property (weak, nonatomic) IBOutlet UITextField *patientID;
@property (weak, nonatomic) IBOutlet UILabel *selectedPatientName;
@property (weak, nonatomic) IBOutlet UIImageView *selectedPatientImage;
@property (weak, nonatomic) IBOutlet UIToolbar *patientChooserToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeScreenButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addPatientButton;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

- (IBAction)closeScreen:(id)sender;
- (IBAction)addPatient:(id)sender;

@end