#import "Category.h"
#import "TGSymbolCreatorViewController.h"

@interface TGCategoryController : NSObject

- (NSArray*)loadCategoriesFromCoreData;
- (Category*)loadCategoryWithID:(int)categoryID;

- (void)loadCategoriesFromBackendWithSuccessHandler:(void(^)())successHandler
                                        failHandler:(void(^)(NSString *error))failHandler;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end