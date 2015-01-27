#import "TGCategoryController.h"

@implementation TGCategoryController

- (id)init
{
    self = [super init];
    if (self) {
        [self setManagedObjectContext:[(AppDelegate*)[UIApplication sharedApplication].delegate backgroundObjectContext]];
    }
    return self;
}

- (NSArray*)loadCategoriesFromCoreData
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:[self managedObjectContext]];
    
    [fetchRequest setEntity:entity];
    
    return [[self managedObjectContext]executeFetchRequest:fetchRequest error:&err];
}

- (Category*)loadCategoryWithID:(int)categoryID
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverID == %d", categoryID];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    return [[[self managedObjectContext]executeFetchRequest:fetchRequest error:&err]objectAtIndex:0];
}

- (void)loadCategoriesFromBackendWithSuccessHandler:(void(^)())successHandler
                                        failHandler:(void(^)(NSString *error))failHandler
{
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@categories", TAGARELA_HOST]]];
    [mutableURLRequest setHTTPMethod:@"GET"];
    [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    [NSURLConnection sendAsynchronousRequest:mutableURLRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *returnData, NSError *error) {
        @try {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:nil];
            
            for (NSDictionary *serverCategory in json) {
                int serverID = [[serverCategory objectForKey:@"id"]intValue];
                
                if (![self categoryExistsWithID:serverID]) {
                    Category *category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:[self managedObjectContext]];
                    [category setName:[serverCategory objectForKey:@"name"]];
                    [category setServerID:[[serverCategory objectForKey:@"id"]intValue]];
                    [category setRed:[[serverCategory objectForKey:@"red"]intValue]];
                    [category setGreen:[[serverCategory objectForKey:@"green"]intValue]];
                    [category setBlue:[[serverCategory objectForKey:@"blue"]intValue]];
                    
                    if (![[self managedObjectContext]save:nil]) {
                        failHandler(NSLocalizedString(@"errorMessageInsertingCategory", nil));
                    }
                }
            }
        }
        @catch (NSException *exception) {
            failHandler([exception reason]);
        }
        @finally {
            successHandler();
        }
    }];
}

- (BOOL)categoryExistsWithID:(int)serverID
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverID == %d", serverID];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    if ([[[self managedObjectContext]executeFetchRequest:fetchRequest error:&err]count] > 0) {
        return YES;
    }
    
    return NO;
}

@end