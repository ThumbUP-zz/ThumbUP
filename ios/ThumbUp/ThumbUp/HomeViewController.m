//
//  FirstViewController.m
//  HitchMike
//
//  Created by Jad on 11/05/13.
//  Copyright (c) 2013 AngelHack. All rights reserved.
//

#import "HomeViewController.h"
#import "DriverViewController.h"

#define HOME_VIEWCONTROLLER_TITLE @"Home"
#define DRIVER_VIEWCONTROLLER_ @"Driver"
#define DRIVER_DETAILVIEWCONTROLLER_TITLE @"Driver detail"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(HOME_VIEWCONTROLLER_TITLE,HOME_VIEWCONTROLLER_TITLE);
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}
							
- (IBAction) driverButtonSelected:(id)sender {
    UIViewController * driverViewController = [[DriverViewController alloc] initWithNibName:NSStringFromClass([DriverViewController class]) bundle:nil];
    [self.navigationController pushViewController:driverViewController animated:YES];
}

- (IBAction) passengerButtonSelected:(id)sender {
#warning not implemented yet
}

@end
