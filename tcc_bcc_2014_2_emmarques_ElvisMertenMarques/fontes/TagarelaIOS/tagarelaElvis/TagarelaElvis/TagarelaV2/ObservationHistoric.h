//
//  ObservationHistoric.h
//  Tagarela
//
//  Created by Alan Filipe Cardozo Fabeni on 09/08/13.
//  Copyright (c) 2013 Alan Filipe Cardozo Fabeni. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ObservationHistoric : NSManagedObject

@property (nonatomic) NSDate *date;
@property (nonatomic, retain) NSString * observation;
@property (nonatomic) int16_t serverID;
@property (nonatomic) int16_t userID;
@property (nonatomic) int16_t tutorID;

@end
