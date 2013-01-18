//
//  ViewController.m
//  Walk
//
//  Created by Daniel Burke on 1/17/13.
//  Copyright (c) 2013 Daniel Burke. All rights reserved.
//

#import "ViewController.h"
#import "WalkRouteViewController.h"
#import <QuartzCore/QuartzCore.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ViewController ()

@end

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated{
    [self resetWalk];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = nil;
    _isWalking = NO;
    _maxLat = _maxLong = _minLat = _minLong = 0;
    
    //CUSTOM NAV BAR
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav"] forBarMetrics:UIBarMetricsDefault];
    }
    self.navigationItem.hidesBackButton = YES;
    
    _navContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    
    UIImage *logoImage = [UIImage imageNamed:@"nav_logo"];
    UIImage *logoImageDown = [UIImage imageNamed:@"nav_logo"];
    _navLogo = [[UIButton alloc] initWithFrame:CGRectMake(110.f, 0, 88.f, 44.f)];
    [_navLogo setBackgroundImage:logoImage forState:UIControlStateNormal];
    [_navLogo setBackgroundImage:logoImageDown forState:UIControlStateHighlighted];
    [_navContainer addSubview:_navLogo];
    [self.navigationItem setTitleView:_navContainer];
    
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
    background.frame = [[UIScreen mainScreen] bounds];
    [self.view addSubview:background];
    
    _points = [[NSMutableArray alloc] initWithCapacity:1000];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self; // Tells the location manager to send updates to this object
    
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
	_containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    _containerView.backgroundColor = [UIColor grayColor];
	[self.view addSubview:self.containerView];
    
    _map = [[MKMapView alloc] initWithFrame:CGRectMake(20.f, 20.f, 280.f, 280.f)];
    [_map.layer setBorderColor:UIColorFromRGB(0x33d6ff).CGColor];
    [_map.layer setBorderWidth:10.f];
    _map.showsUserLocation = YES;
    _map.delegate = self;
    
    UIView *mapShadowFrame = [[UIView alloc] initWithFrame:CGRectMake(20.f, 20.f, 280.f, 280.f)];
    mapShadowFrame.layer.shadowOffset = CGSizeMake(10.0, 10.0);
    mapShadowFrame.layer.shadowColor = [[UIColor blackColor] CGColor];
    mapShadowFrame.layer.shadowRadius = 5.0;
    mapShadowFrame.layer.shadowOpacity = 0.8;
    mapShadowFrame.clipsToBounds = NO;

    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(_locationManager.location.coordinate.latitude, _locationManager.location.coordinate.longitude);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.001, 0.001);
    MKCoordinateRegion region = MKCoordinateRegionMake(coord, span);
    [_map setRegion:region];
    
    [self.view addSubview:mapShadowFrame];
    [self.view addSubview:_map];
    
    _endWalkBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _endWalkBtn.frame = CGRectMake(self.view.frame.size.width - 150.f, 360.f, 130.f, 44.f);
    
    [_endWalkBtn setTitle:@"END WALK" forState:UIControlStateNormal];
    [_endWalkBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _endWalkBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue Condensed Bold" size:12.f];
    [_endWalkBtn setBackgroundImage:[UIImage imageNamed:@"walk_btn"] forState:UIControlStateNormal];
    [_endWalkBtn setBackgroundImage:[UIImage imageNamed:@"walk_btn_active"] forState:UIControlStateHighlighted];
    [_endWalkBtn addTarget:self action:@selector(createRoute) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_endWalkBtn];
    [_endWalkBtn setHidden:YES];
    
    _startWalkBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _startWalkBtn.frame = CGRectMake(20.f, 360.f, 130.f, 44.f);
    
    [_startWalkBtn setTitle:@"START A WALK" forState:UIControlStateNormal];
    [_startWalkBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _startWalkBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue Condensed Bold" size:12.f];
    [_startWalkBtn setBackgroundImage:[UIImage imageNamed:@"walk_btn"] forState:UIControlStateNormal];
    [_startWalkBtn setBackgroundImage:[UIImage imageNamed:@"walk_btn_active"] forState:UIControlStateHighlighted];
    [_startWalkBtn addTarget:self action:@selector(startWalk) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_startWalkBtn];
    
    _resetBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _resetBtn.frame = CGRectMake(20.f, 360.f, 130.f, 44.f);
    
    [_resetBtn setTitle:@"RESTART" forState:UIControlStateNormal];
    [_resetBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _resetBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue Condensed Bold" size:12.f];
    [_resetBtn setBackgroundImage:[UIImage imageNamed:@"walk_btn"] forState:UIControlStateNormal];
    [_resetBtn setBackgroundImage:[UIImage imageNamed:@"walk_btn_active"] forState:UIControlStateHighlighted];
    [_resetBtn addTarget:self action:@selector(resetWalk) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_resetBtn];
    [_resetBtn setHidden:YES];
    
    
    UILabel *totalDistanceTitle = [[UILabel alloc] initWithFrame:CGRectMake(20.f, 300.f, 130.f, 40.f)];
    totalDistanceTitle.text = @"Total Distance";
    [totalDistanceTitle setTextAlignment:NSTextAlignmentCenter];
    [totalDistanceTitle setBackgroundColor:[UIColor clearColor]];
    [totalDistanceTitle setTextColor:UIColorFromRGB(0x33d6ff)];
    [totalDistanceTitle setFont:[UIFont fontWithName:@"Helvetica Neue Condensed Bold" size:40.f]];
    [self.view addSubview:totalDistanceTitle];
    
    _totalDistanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.f, 320.f, 130.f, 40.f)];
    [_totalDistanceLabel setTextAlignment:NSTextAlignmentCenter];
    [_totalDistanceLabel setBackgroundColor:[UIColor clearColor]];
    [_totalDistanceLabel setTextColor:UIColorFromRGB(0x33d6ff)];
    [_totalDistanceLabel setFont:[UIFont fontWithName:@"Helvetica Neue Condensed Bold" size:40.f]];
    _totalDistanceLabel.text = @"-";
    
    UILabel *totalTimeTitle = [[UILabel alloc] initWithFrame:CGRectMake(170.f, 300.f, 130.f, 40.f)];
    totalTimeTitle.text = @"Total Time";
    [totalTimeTitle setTextAlignment:NSTextAlignmentCenter];
    [totalTimeTitle setBackgroundColor:[UIColor clearColor]];
    [totalTimeTitle setTextColor:UIColorFromRGB(0x33d6ff)];
    [totalTimeTitle setFont:[UIFont fontWithName:@"Helvetica Neue Condensed Bold" size:40.f]];
    [self.view addSubview:totalTimeTitle];
    
    _totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(170.f, 320.f, 130.f, 40.f)];
    [_totalTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [_totalTimeLabel setBackgroundColor:[UIColor clearColor]];
    [_totalTimeLabel setTextColor:UIColorFromRGB(0x33d6ff)];
    [_totalTimeLabel setFont:[UIFont fontWithName:@"Helvetica Neue Condensed Bold" size:40.f]];
    _totalTimeLabel.text = @"00:00";
    
    [self.view addSubview:_totalDistanceLabel];
    [self.view addSubview:_totalTimeLabel];
    
    [_map removeOverlays:_map.overlays];
    
}

- (UIImage *)imageByCropping:(MKMapView *)imageToCrop toRect:(CGRect)rect
{
    CGSize pageSize = rect.size;
    UIGraphicsBeginImageContext(pageSize);
    
    CGContextRef resizedContext = UIGraphicsGetCurrentContext();
    [imageToCrop.layer renderInContext:resizedContext];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)updateTimeLabel:(NSTimer *)timer{
    NSInteger secondsSinceStart = (NSInteger)[[NSDate date] timeIntervalSinceDate:_startTime];
    
    NSInteger seconds = secondsSinceStart % 60;
    NSInteger minutes = (secondsSinceStart / 60) % 60;
    NSInteger hours = secondsSinceStart / (60 * 60);
    NSString *result = nil;
    if (hours > 0) {
        result = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    }
    else {
        result = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }
    
    _totalTime = result;
    _totalTimeLabel.text = result;
}

//
- (void)switchToBackgroundMode:(BOOL)background
{
    if (_isWalking)
    {
        NSLog(@"Switch to background");
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
    }
    else
    {
        NSLog(@"Switch to foreground");
    }
}

- (void)createRoute{
    
    NSInteger i = 0;
    CLLocationCoordinate2D *polylineCoords = malloc(sizeof(CLLocationCoordinate2D) * _points.count);
    
    //LOOP THROUGH THE POINTS TO CREATEA COORDINATE SET
    for (NSDictionary *stationDictionary in _points) {
        // 4
        CLLocationDegrees latitude = [[stationDictionary objectForKey:@"Lat"] doubleValue];
        CLLocationDegrees longitude = [[stationDictionary objectForKey:@"Long"] doubleValue];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        polylineCoords[i] = coordinate;
        i++;
    }
    
    //CREATE ROUTELINE TO BE ADDED TO THE MAP
    _routeLine = [MKPolyline polylineWithCoordinates:polylineCoords count:_points.count];
    [_map addOverlay:_routeLine];

    //CLEAN UP A BIT
    free(polylineCoords);
    
    //CREATE SNAPSHOT OF MAP OVERLAY
    CGRect clippedRect = CGRectMake(20.f, 20.f, 280.f, 280.f);
    UIImageView *picture = [[UIImageView alloc] initWithFrame:CGRectMake((90.f * _numSnapShots) + 10.f, 10.f, 280.f, 280.f)];
    picture.image = [self imageByCropping:_map toRect:clippedRect];
    
    //STOP TIMER
    [_walkRouteTimer invalidate];
    
    //PREPARE NEW VIEW AND PUSH
    WalkRouteViewController *myWalk= [[WalkRouteViewController alloc] init];
    myWalk.walkRouteImage = picture.image;
    myWalk.walkRouteInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                            _totalDistanceLabel.text, @"Distance",
                            _totalTime, @"Time",
                            [NSString stringWithFormat:@"%2f", _maxLat], @"MaxLat",
                            [NSString stringWithFormat:@"%2f", _maxLong], @"MaxLong",
                            [NSString stringWithFormat:@"%2f", _minLat], @"MinLat",
                            [NSString stringWithFormat:@"%2f", _minLong], @"MinLong",
                            _points, @"Points",
                            nil];
    _isWalking = NO;
    
    [self.navigationController pushViewController:myWalk animated:YES];
    
}


- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{    NSString *transactionLat = [NSString stringWithFormat:@"%f", newLocation.coordinate.latitude];
    NSString *transactionLong = [NSString stringWithFormat:@"%f", newLocation.coordinate.longitude];

    NSDictionary *point = [[NSDictionary alloc] initWithObjectsAndKeys:transactionLat, @"Lat", transactionLong, @"Long", nil];
    
    _maxLat = ([transactionLat doubleValue] > _maxLat || _maxLat == 0) ? [transactionLat doubleValue] : _maxLat;
    _maxLong = ([transactionLong doubleValue] > _maxLong || _maxLong == 0) ? [transactionLong doubleValue] : _maxLong;
    
    _minLat = ([transactionLat doubleValue] < _minLat || _minLat == 0) ? [transactionLat doubleValue] : _minLat;
    _minLong = ([transactionLong doubleValue] < _minLong || _minLong == 0) ? [transactionLong doubleValue] : _minLong;
    
    CLLocationDistance meters = [newLocation distanceFromLocation:oldLocation];
    NSString *distance = [NSString stringWithFormat:@"%f", meters];
    
    //CALCULATE AND ADD TOTAL DISTANCE
    NSNumber *numberThatIsStored = [ NSNumber numberWithDouble:meters ];
    _totalDistance += numberThatIsStored.doubleValue;
    _totalDistanceLabel.text = [NSString stringWithFormat:@"%2f", _totalDistance];
    
    [_pointsDistances addObject:distance];
    [_points addObject:point];
    
    CLLocationCoordinate2D *polylineCoords = malloc(sizeof(CLLocationCoordinate2D) * 2);
    polylineCoords[0] = oldLocation.coordinate;
    polylineCoords[1] = newLocation.coordinate;
    
    _routeLine = [MKPolyline polylineWithCoordinates:polylineCoords count:2];
    [_map addOverlay:_routeLine];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
}


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor redColor];
    polylineView.lineWidth = 10.0;
    
    return polylineView;
}


-(void)startWalk{
    
    _isWalking = YES;
    
    [_map removeOverlays:_map.overlays];
    
    UIImage *logoImage = [UIImage imageNamed:@"walking_logo"];
    UIImage *logoImageDown = [UIImage imageNamed:@"walking_logo"];
    _navLogo.frame= CGRectMake(70.f, 0, 176.f, 44.f);
    [_navLogo setBackgroundImage:logoImage forState:UIControlStateNormal];
    [_navLogo setBackgroundImage:logoImageDown forState:UIControlStateHighlighted];
    
    [_endWalkBtn setHidden:NO];
    [_resetBtn setHidden:NO];
    [_startWalkBtn setHidden:YES];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    _startTime = [NSDate date];
    _walkRouteTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimeLabel:) userInfo:nil repeats:YES];
    [_walkRouteTimer fire];
    
}

-(void)resetWalk{
    _isWalking = NO;
    [_map removeOverlays:_map.overlays];
    
    UIImage *logoImage = [UIImage imageNamed:@"nav_logo"];
    UIImage *logoImageDown = [UIImage imageNamed:@"nav_logo"];
    _navLogo.frame= CGRectMake(110.f, 0, 88.f, 44.f);
    [_navLogo setBackgroundImage:logoImage forState:UIControlStateNormal];
    [_navLogo setBackgroundImage:logoImageDown forState:UIControlStateHighlighted];
    
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    
    [_resetBtn setHidden:YES];
    [_endWalkBtn setHidden:YES];
    [_startWalkBtn setHidden:NO];
    
    [_walkRouteTimer invalidate];
    
    _totalDistanceLabel.text = @"-";
    _totalDistance = 0;
    
    _totalTimeLabel.text = @"00:00";
    _totalTime = nil;
}

-(void)centerMap{
//    MKCoordinateRegion region = _map.region;
//    region.center = centerCoordinate;
//    region.span.longitudeDelta /= ratioZoomMax; // Bigger the value, closer the map view
//    region.span.latitudeDelta /= ratioZoomMax;
//    [self.mapView setRegion:region animated:YES];
}


@end
