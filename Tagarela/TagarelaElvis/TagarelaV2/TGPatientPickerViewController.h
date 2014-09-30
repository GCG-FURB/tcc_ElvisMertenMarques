#import "TGTutorPatientsController.h"
#import "PatientsRelationships.h"

@interface TGPatientPickerViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    TGTutorPatientsController *tutorPatientsController;
    NSArray *tutorPatients;
}

@property (weak, nonatomic) IBOutlet UIToolbar *patientListToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelSelectionButton;
@property (weak, nonatomic) IBOutlet UITableView *patientsTableView;

- (IBAction)cancelSelection:(id)sender;

@end