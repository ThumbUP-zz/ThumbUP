#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface AnnotationLocation : NSObject <MKAnnotation> {
    NSString *_name;
    NSString *_address;
    CLLocationCoordinate2D _coordinate;
}

typedef enum {
    AnnotationTypeStart,
    AnnotationTypeFinish,
} AnnotationType;

@property (copy) NSString *name;
@property (copy) NSString *address;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) AnnotationType type;

- (id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate andType:(AnnotationType)type;

@end
