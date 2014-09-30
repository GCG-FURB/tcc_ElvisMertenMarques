#import "User.h"
#import "PatientsRelationships.h"

@interface TGCurrentUserManager : NSObject

+ (id)sharedCurrentUserManager;

@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) PatientsRelationships *selectedTutorPatient;
@property (nonatomic) BOOL isNewUser;
@property (nonatomic, strong) NSDate *lastSync;

@end