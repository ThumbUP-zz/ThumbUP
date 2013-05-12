//
//  OnthegoViewController.m
//  HitchMike
//
//  Created by Jad on 12/05/13.
//  Copyright (c) 2013 AngelHack. All rights reserved.
//

#import "OnthegoViewController.h"
#import "DriverRideModel.h"
#import "RideEventModel.h"
#import "RideEventTableViewCell.h"
#import <MapKit/MapKit.h>

#define HOME_ONTHEGOVIEWCONTROLLER_TITLE @"Current ride"

@interface OnthegoViewController ()

@property (nonatomic, retain) DriverRideModel * model;
@property (nonatomic, retain) IBOutlet MKMapView * mapView;
@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, retain) NSArray * events;

@end

@implementation OnthegoViewController

@synthesize mapView = _mapView;
@synthesize tableView = _tableView;
@synthesize events = _events;
- (NSArray *)events {
    if (_events == nil) {
        RideEventModel * event1 = [[RideEventModel alloc] initWithTime:@"14:00" andTitle:@"Ride started"];
        RideEventModel * event2 = [[RideEventModel alloc] initWithTime:@"14:09" andTitle:@"Ride approaching. Meeting expected in 5 minutes"];
        RideEventModel * event3 = [[RideEventModel alloc] initWithTime:@"14:14" andTitle:@"Ride arrived at meet point. Enjoy!"];
        _events = [NSArray arrayWithObjects:event1, event2, event3, nil];
    }
    return _events;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andModel:(DriverRideModel *)model
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.model = model;
        self.title = NSLocalizedString(HOME_ONTHEGOVIEWCONTROLLER_TITLE,HOME_ONTHEGOVIEWCONTROLLER_TITLE);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.events count];
}

- (RideEventModel *) eventAtIndex:(NSUInteger)index {
    return (RideEventModel *)[self.events objectAtIndex:index];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *eventCellIdentifier = @"eventCellIdentifier";
    
    RideEventTableViewCell *cell = (RideEventTableViewCell *)[tableView dequeueReusableCellWithIdentifier:eventCellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([RideEventTableViewCell class]) owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    RideEventModel * eventModel =  [self eventAtIndex:indexPath.row];
    cell.timeLabel.text = eventModel.time;
    cell.titleLabel.text = eventModel.title;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40.0)];
    [headerLabel setBackgroundColor:[UIColor orangeColor]];
    [headerLabel setText:@"Ride History"];
    return headerLabel;
}

@end
