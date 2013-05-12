//
//  RoutesViewController.m
//  TestMap
//
//  Created by Meski Badr on 12/05/13.
//  Copyright (c) 2013 Meski Badr. All rights reserved.
//

#import "RoutesViewController.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "AnnotationLocation.h"

@interface RoutesViewController ()

@end

@implementation RoutesViewController

@synthesize location = _location;
@synthesize destination = _destination;
@synthesize destinationString = _destinationString;

@synthesize routes = _routes;
- (NSMutableArray *)routes {
    if(!_routes) {
        _routes = [NSMutableArray array];
    }
    return _routes;
}

@synthesize mapViews = _mapViews;
- (NSMutableArray *)mapViews {
    if(!_mapViews) {
        _mapViews = [NSMutableArray array];
    }
    return _mapViews;
}

@dynamic mapView;
- (MKMapView *)mapView {
    if(self.pageControl.currentPage >= 0 && [self.pageControl currentPage] < [self.mapViews count]) {
        return [self.mapViews objectAtIndex:[self.pageControl currentPage]];
    }
    return nil;
}

- (void)startRouteRequest {
    AFHTTPClient *_httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://maps.googleapis.com/"]];
    [_httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[NSString stringWithFormat:@"%f,%f", self.location.coordinate.latitude, self.location.coordinate.longitude] forKey:@"origin"];
    [parameters setObject:[NSString stringWithFormat:@"%f,%f", self.destination.coordinate.latitude, self.destination.coordinate.longitude] forKey:@"destination"];
    [parameters setObject:@"true" forKey:@"sensor"];
    [parameters setObject:@"true" forKey:@"alternatives"];
    
    NSLog(@"location : %f,%f",self.location.coordinate.latitude, self.location.coordinate.longitude);
    NSLog(@"destination : %f,%f",self.destination.coordinate.latitude, self.destination.coordinate.longitude);
    
    NSMutableURLRequest *request = [_httpClient requestWithMethod:@"GET" path: @"maps/api/directions/json" parameters:parameters];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            if (response.statusCode == 200) {
                                                                                                [self parseResponse:JSON];
                                                                                                [self layoutMapViews];
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
        [[self.mapViews objectAtIndex:[self.routes indexOfObject:route]] addOverlay:polyLine];
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
        [[self.mapViews objectAtIndex:[self.routes indexOfObject:route]]  addAnnotation:endAnnotation];
    }
}

- (void)layoutMapViews {
    for (int i = 0; i < self.routes.count; i++) {
        CGRect frame;
        frame.origin.x = self.scrollView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = self.scrollView.frame.size;
        
        MKMapView *mapView = [[MKMapView alloc] initWithFrame:frame];
        mapView.delegate = self;
        mapView.showsUserLocation = YES;
        mapView.scrollEnabled = NO;
        
        [self.scrollView addSubview:mapView];
        [self.mapViews addObject:mapView];
    }
    
    self.pageControl.numberOfPages = self.routes.count;
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * self.routes.count, self.scrollView.frame.size.height);
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

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

#pragma mark - Controller LifeCycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andDestinationAddress:(NSString *)destinationAddress {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.destinationString = destinationAddress;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [self.scrollView setPagingEnabled:YES];
    
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = self.routes.count;
    
    [geocoder geocodeAddressString:@"27 ter rue du Progrès, Montreuil" completionHandler:^(NSArray *placemarks, NSError *error) {
        if(placemarks) {
            self.location = ((CLPlacemark *)[placemarks objectAtIndex:0]).location;
            
            [geocoder geocodeAddressString:self.destinationString completionHandler:^(NSArray *placemarks, NSError *error) {
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
