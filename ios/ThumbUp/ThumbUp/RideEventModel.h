//
//  RideEventModel.h
//  HitchMike
//
//  Created by Jad on 12/05/13.
//  Copyright (c) 2013 AngelHack. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RideEventModel : NSObject

@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSString * title;

- (id) initWithTime:(NSString *)time andTitle:(NSString *)title;

@end
