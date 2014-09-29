#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) int16_t serverID;
@property (nonatomic) int16_t type;
@property (nonatomic, retain) NSData * picture;

@end