//
//  DriverDetailViewController.h
//  HitchMike
//
//  Created by Jad on 12/05/13.
//  Copyright (c) 2013 AngelHack. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DriverRideModel;

@interface DriverDetailViewController : UIViewController

@property (nonatomic, retain) IBOutlet UITextField * startPointLabel;
@property (nonatomic, retain) IBOutlet UITextField * endPointLabel;
@property (nonatomic, retain) IBOutlet UITextField * dateLabel;
@property (nonatomic, retain) IBOutlet UITextField * timeLabel;
@property (nonatomic, retain) IBOutlet UITextField * recurrencyLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andModel:(DriverRideModel *)model;

@end
