//
//  RideEventModel.m
//  HitchMike
//
//  Created by Jad on 12/05/13.
//  Copyright (c) 2013 AngelHack. All rights reserved.
//

#import "RideEventModel.h"

@implementation RideEventModel

- (id) initWithTime:(NSString *)time andTitle:(NSString *)title {
    self = [super init];
    if (self) {
        self.time = time;
        self.title = title;
    }
    return self;
}


@end
