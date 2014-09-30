#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Symbol;

@interface Category : NSManagedObject

@property (nonatomic) int16_t blue;
@property (nonatomic) int16_t green;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) int16_t red;
@property (nonatomic) int16_t serverID;
@property (nonatomic, retain) NSSet *symbols;
@end

@interface Category (CoreDataGeneratedAccessors)

- (void)addSymbolsObject:(Symbol *)value;
- (void)removeSymbolsObject:(Symbol *)value;
- (void)addSymbols:(NSSet *)values;
- (void)removeSymbols:(NSSet *)values;

@end