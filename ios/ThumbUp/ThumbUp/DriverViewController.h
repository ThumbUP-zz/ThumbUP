//
//  DriverViewController.h
//  HitchMike
//
//  Created by Jad on 12/05/13.
//  Copyright (c) 2013 AngelHack. All rights reserved.
//

#import <UIKit/UIKit.h>
#define HOME_DRIVERVIEWCONTROLLER_TITLE @"Share a ride"

@interface DriverViewController : UIViewController

@property (nonatomic, retain) IBOutlet UITextField * startPointLabel;
@property (nonatomic, retain) IBOutlet UITextField * endPointLabel;

@end
