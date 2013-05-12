//
//  DriverDetailViewController.m
//  HitchMike
//
//  Created by Jad on 12/05/13.
//  Copyright (c) 2013 AngelHack. All rights reserved.
//

#import "DriverDetailViewController.h"
#import "DriverRideModel.h"
#import "DriverViewController.h"
#import "RoutesViewController.h"

@interface DriverDetailViewController ()

@property (nonatomic, retain) DriverRideModel * model;


@end

@implementation DriverDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andModel:(DriverRideModel *)model
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.model = model;
        [self.model setDate:@"12/05/2013"];
        [self.model setTime:@"14:00"];
        [self.model setRecurrenceDays:@"Mon, Wed, Fri"];
        self.title = NSLocalizedString(HOME_DRIVERVIEWCONTROLLER_TITLE,HOME_DRIVERVIEWCONTROLLER_TITLE);
    }
    return self;
}

- (IBAction)pushRoutesViewController:(id)sender {
    RoutesViewController *routesViewController = [[RoutesViewController alloc] initWithNibName:NSStringFromClass([RoutesViewController class]) bundle:[NSBundle mainBundle] andModel:self.model];
    [self.navigationController pushViewController:routesViewController animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.startPointLabel setText:self.model.startLocation];
    [self.endPointLabel setText:self.model.endLocation];
    [self.dateLabel setText:self.model.date];
    [self.timeLabel setText:self.model.time];
    [self.recurrencyLabel setText:self.model.recurrenceDays];
}

@end
