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

#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "AnnotationLocation.h"

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
        self.destinationString = model.endLocation;
        self.title = NSLocalizedString(HOME_ONTHEGOVIEWCONTROLLER_TITLE,HOME_ONTHEGOVIEWCONTROLLER_TITLE);
    }
    return self;
}

#pragma mark UITableView delegate/datasource methods
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


- (void)startRouteRequest {
    AFHTTPClient *_httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://maps.googleapis.com/"]];
    [_httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[NSString stringWithFormat:@"%f,%f", self.location.coordinate.latitude, self.location.coordinate.longitude] forKey:@"origin"];
    [parameters setObject:[NSString stringWithFormat:@"%f,%f", self.destination.coordinate.latitude, self.destination.coordinate.longitude] forKey:@"destination"];
    [parameters setObject:@"true" forKey:@"sensor"];
    
    NSLog(@"location : %f,%f",self.location.coordinate.latitude, self.location.coordinate.longitude);
    NSLog(@"destination : %f,%f",self.destination.coordinate.latitude, self.destination.coordinate.longitude);
    
    NSMutableURLRequest *request = [_httpClient requestWithMethod:@"GET" path: @"maps/api/directions/json" parameters:parameters];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            if (response.statusCode == 200) {
                                                                                                [self parseResponse:JSON];
                                                                                                [self layoutMapView];
                                                                                                [self drawRoutes];
                                                                                                [self putPins];
                                                                                            } else {
                                                                                                
                                                                                            }
                                                                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            
                                                                                        }];
    [_httpClient enqueueHTTPRequestOperation:operation];
}

- (void)parseResponse:(NSDictionary *)response {
    NSArray *routes = [response objectForKey:@"routes"];
    for (NSDictionary *route in routes) {
        NSString *overviewPolyline = [[route objectForKey: @"overview_polyline"] objectForKey:@"points"];
        [self.routes addObject:[self decodePolyLine:overviewPolyline]];
    }
}

#pragma mark Display
-(NSMutableArray *)decodePolyLine:(NSString *)encodedStr {
    NSMutableString *encoded = [[NSMutableString alloc] initWithCapacity:[encodedStr length]];
    [encoded appendString:encodedStr];
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, [encoded length])];
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:location];
    }
    
    return array;
}

- (void)drawRoutes {
    for (NSArray *route in self.routes) {
        NSInteger numberOfSteps = route.count;
        
        CLLocationCoordinate2D coordinates[numberOfSteps];
        for (NSInteger index = 0; index < numberOfSteps; index++) {
            CLLocation *location = [route objectAtIndex:index];
            CLLocationCoordinate2D coordinate = location.coordinate;
            
            coordinates[index] = coordinate;
        }
        
        MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:numberOfSteps];
        [self.mapView addOverlay:polyLine];
    }
}

- (void)putPins {
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        [self.mapView removeAnnotation:annotation];
    }
    
    CLLocationCoordinate2D endCoordinate;
    endCoordinate.latitude = self.destination.coordinate.latitude;
    endCoordinate.longitude = self.destination.coordinate.longitude;
    
    for (NSArray *route in self.routes) {
        AnnotationLocation *endAnnotation = [[AnnotationLocation alloc] initWithName:@"Arrivée" address:@"" coordinate:endCoordinate andType:AnnotationTypeFinish];
        [self.mapView addAnnotation:endAnnotation];
    }
}

- (void)layoutMapView {
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
}

#pragma MapKit Delegate Methods
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.location.coordinate,1200, 1200);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
    [mapView setRegion:adjustedRegion animated:YES];
}

-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor colorWithRed:106/255.0 green:148/255.0 blue:223/255.0 alpha:1];
    polylineView.alpha = 0.8;
    polylineView.lineWidth = 10.0;
    
    return polylineView;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"Annotation";
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    } else {
        annotationView.annotation = annotation;
    }
    
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    
    if ([annotation isKindOfClass:[AnnotationLocation class]]) {
        annotationView.pinColor = (((AnnotationLocation *)annotation).type == AnnotationTypeStart) ? MKPinAnnotationColorGreen : MKPinAnnotationColorRed;
    }
    else if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        annotationView.pinColor = MKPinAnnotationColorGreen;
    }
    
    return annotationView;
}

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder geocodeAddressString:self.model.startLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if(placemarks) {
            self.location = ((CLPlacemark *)[placemarks objectAtIndex:0]).location;
            
            NSLog(@"%@",self.model.endLocation);
            [geocoder geocodeAddressString:self.model.endLocation completionHandler:^(NSArray *placemarks, NSError *error) {
                if(placemarks) {
                    self.destination = ((CLPlacemark *)[placemarks objectAtIndex:0]).location;
                    [self startRouteRequest];
                }
                else {
                    
                }
            }];
        }
        else {
            
        }
    }];
    
}


@end
