//
//  DriverViewController.m
//  HitchMike
//
//  Created by Jad on 12/05/13.
//  Copyright (c) 2013 AngelHack. All rights reserved.
//

#import "DriverViewController.h"
#import "DriverRideModel.h"
#import "DriverDetailViewController.h"
#import "OnthegoViewController.h"



@interface DriverViewController ()

@property (nonatomic, retain) DriverRideModel * model;

@end


@implementation DriverViewController

@synthesize model = _model;
- (DriverRideModel *)model {
    if (_model == nil) {
        _model = [[DriverRideModel alloc] init];
    }
    return _model;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.model setStartLocation:@"27 ter rue du Progrès, Montreuil"];
        [self.model setEndLocation:@"26 rue de garibaldi, Montreuil"];
        self.title = NSLocalizedString(HOME_DRIVERVIEWCONTROLLER_TITLE,HOME_DRIVERVIEWCONTROLLER_TITLE);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.startPointLabel setText:self.model.startLocation];
    [self.endPointLabel setText:self.model.endLocation];
}

- (IBAction) pushDriverDetailViewController:(id)sender{
    DriverDetailViewController * driverDetailViewController = [[DriverDetailViewController alloc] initWithNibName:NSStringFromClass([DriverDetailViewController class]) bundle:nil andModel:self.model];
    [self.navigationController pushViewController:driverDetailViewController animated:YES];
}

- (IBAction) pushOnTheGoViewController:(id)sender{
    OnthegoViewController * onthegoViewController = [[OnthegoViewController alloc] initWithNibName:NSStringFromClass([OnthegoViewController class]) bundle:nil andModel:self.model];
    [self.navigationController pushViewController:onthegoViewController animated:YES];
}

@end
