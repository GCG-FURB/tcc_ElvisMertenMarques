#import "User.h"

@interface TGUserController : NSObject

- (void)createUserWithName:(NSString*)username
               andPassword:(NSString*)password
                  andEmail:(NSString*)email
                   andType:(int)type
                andPicture:(UIImage*)picture
            successHandler:(void(^)())successHandler
               failHandler:(void(^)(NSString *error))failHandler;

- (void)createUserInDeviceWithName:(NSString*)username
                          andEmail:(NSString*)email
                           andType:(int)type
                       andServerID:(int)serverID
                        andPicture:(UIImage*)picture
                    successHandler:(void(^)())successHandler
                       failHandler:(void(^)(NSString *error))failHandler;

- (UIImage*)loadUserPicture;
- (User*)user;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) BOOL isNewUser;

@end