//
//  DriverRideModel.h
//  HitchMike
//
//  Created by Jad on 12/05/13.
//  Copyright (c) 2013 AngelHack. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
typedef enum {
    DriverRideModelMonday     = 1 << 0,
    DriverRideModelTuesday    = 1 << 1,
    DriverRideModelWednesday  = 1 << 2,
    DriverRideModelThursday   = 1 << 3,
    DriverRideModelFriday     = 1 << 4,
    DriverRideModelSaturday   = 1 << 5,
    DriverRideModelSunday     = 1 << 6,
}DriverRideModelDay;
*/

@interface DriverRideModel : NSObject

@property (nonatomic, retain) NSString * startLocation;
@property (nonatomic, retain) NSString * endLocation;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSString * recurrenceDays;

//@property (nonatomic, assign) DriverRideModelDay recurrenceDays;

@end
