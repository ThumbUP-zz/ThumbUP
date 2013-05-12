//
//  OnthegoViewController.h
//  HitchMike
//
//  Created by Jad on 12/05/13.
//  Copyright (c) 2013 AngelHack. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class DriverRideModel;

@interface OnthegoViewController : UIViewController<MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) CLLocation *destination;
@property (strong, nonatomic) NSString *destinationString;
@property (strong, nonatomic) NSMutableArray *routes;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andModel:(DriverRideModel *)model;

@end
