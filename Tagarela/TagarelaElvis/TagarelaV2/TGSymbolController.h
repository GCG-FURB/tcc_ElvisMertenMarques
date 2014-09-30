#import "Category.h"
#import "Symbol.h"
#import "TGUserController.h"
#import "PatientSymbol.h"
#import "TGCategoryController.h"

@class TGCategoryController;

@interface TGSymbolController : NSObject <AVAudioRecorderDelegate>
{
    AVAudioRecorder *audioRecorder;
	SystemSoundID soundID;
    NSData *audioDataToStore;
    TGUserController *userController;
    TGCategoryController *categoryController;
    NSManagedObjectContext *symbolManagedObjectContext;
}

- (void)createSymbolWithName:(NSString*)name
                  andPicture:(UIImage*)picture
                andVideoLink:(NSString*)videoLink
                    andSound:(NSData*)sound
                 andCategory:(Category*)category
              successHandler:(void(^)())successHandler
                 failHandler:(void(^)(NSString *error))failHandler;

- (void)createSymbolInBackendWithName:(NSString *)name
                           andPicture:(UIImage*)picture
                         andVideoLink:(NSString*)videoLink
                             andSound:(NSData*)sound
                          andCategory:(Category*)category
                     isUnsyncedSymbol:(BOOL)isUnsyncedSymbol
                       successHandler:(void(^)())successHandler
                          failHandler:(void(^)(NSString *error))failHandler;


- (NSArray*)loadSymbolsFromCoreData;
- (NSArray*)loadSymbolsFromCoreDataWithCategory:(Category*)category;
- (Symbol*)symbolWithID:(int)symbolID;
- (NSArray*)loadSymbolsWithName:(NSString*)symbolName;
- (BOOL)patientWithID:(int)patientID hasSymbolWithID:(int)symbolID;

- (void)createRelationshipInBackendBetweenPatientAndSymbolWithSymbolID:(int)symbolID
                                                        successHandler:(void(^)())successHandler
                                                           failHandler:(void(^)(NSString *error))failHandler;

- (void)loadSymbolsFromBackendWithSuccessHandler:(void(^)())successHandler
                                     failHandler:(void(^)(NSString *error))failHandler;

- (void)loadPatientSymbolsFromBackendWithSuccessHandler:(void(^)())successHandler
                                            failHandler:(void(^)(NSString *error))failHandler;

- (void)startRecordingWithFilePath:(NSString*)recorderFilePath;
- (void)stopRecording;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Symbol *unsycedSymbol;

@end