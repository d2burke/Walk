//
//  WalkRouteViewController.m
//  Walk
//
//  Created by Daniel Burke on 1/17/13.
//  Copyright (c) 2013 Daniel Burke. All rights reserved.
//

#import "WalkRouteViewController.h"
#import <QuartzCore/QuartzCore.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface WalkRouteViewController ()

@end

@implementation WalkRouteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    
    //CUSTOM NAV BAR
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav"] forBarMetrics:UIBarMetricsDefault];
    }
    //self.navigationItem.hidesBackButton = YES;
    
   // [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[UIImage imageNamed:@"back_btn"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    UIImage *backImage = [UIImage imageNamed:@"back_btn"];
    UIImage *backImageDown = [UIImage imageNamed:@"back_btn_active"];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, 88.f, 44.f)];
    [backBtn setBackgroundImage:backImage forState:UIControlStateNormal];
    [backBtn setBackgroundImage:backImageDown forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [_navContainer addSubview:backBtn];
    
    UIImage *logoImage = [UIImage imageNamed:@"nav_logo"];
    UIImage *logoImageDown = [UIImage imageNamed:@"nav_logo"];
    UIButton *logoBtn = [[UIButton alloc] initWithFrame:CGRectMake(140.f, 0, 88.f, 44.f)];
    [logoBtn setBackgroundImage:logoImage forState:UIControlStateNormal];
    [logoBtn setBackgroundImage:logoImageDown forState:UIControlStateHighlighted];
    [_navContainer addSubview:logoBtn];
    
    [self.navigationItem setTitleView:_navContainer];
    
    NSLog(@"%@", _walkRouteInfo);
    
//    UIImageView *walkRouteImageView = [[UIImageView alloc] initWithImage:_walkRouteImage];
//    walkRouteImageView.frame = CGRectMake(20.f, 20.f, 280.f, 280.f);
//    [self.view addSubview:walkRouteImageView];
    
    _map = [[MKMapView alloc] initWithFrame:CGRectMake(20.f, 20.f, 280.f, 280.f)];
    [_map.layer setBorderColor:UIColorFromRGB(0x33d6ff).CGColor];
    [_map.layer setBorderWidth:10.f];
    _map.showsUserLocation = YES;
    _map.delegate = self;
    
    
    double max_long = [[_walkRouteInfo objectForKey:@"MaxLong"] doubleValue];
    double min_long = [[_walkRouteInfo objectForKey:@"MinLong"] doubleValue];
    double max_lat = [[_walkRouteInfo objectForKey:@"MaxLat"] doubleValue];
    double min_lat = [[_walkRouteInfo objectForKey:@"MinLat"] doubleValue];
    
    CLLocationDegrees latitude = (max_lat + max_lat) / 2;
    CLLocationDegrees longitude = (max_long + min_long) / 2;
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(latitude, longitude);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateSpanMake(abs(max_lat) + abs(min_lat), abs(max_long) + abs(min_long));
    MKCoordinateRegion region = MKCoordinateRegionMake(coord, span);
    [_map setRegion:region];
    [self.view addSubview:_map];
    
    [_map setShowsUserLocation:NO];
    
    NSInteger i = 0;
    NSArray *points = [_walkRouteInfo objectForKey:@"Points"];
    CLLocationCoordinate2D *polylineCoords = malloc(sizeof(CLLocationCoordinate2D) *points.count);
    
    //LOOP THROUGH THE POINTS TO CREATEA COORDINATE SET
    for (NSDictionary *stationDictionary in points) {
        // 4
        CLLocationDegrees latitude = [[stationDictionary objectForKey:@"Lat"] doubleValue];
        CLLocationDegrees longitude = [[stationDictionary objectForKey:@"Long"] doubleValue];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        polylineCoords[i] = coordinate;
        i++;
    }
    
    //CREATE ROUTELINE TO BE ADDED TO THE MAP
    _routeLine = [MKPolyline polylineWithCoordinates:polylineCoords count:points.count];
    [_map addOverlay:_routeLine];
    
    //CLEAN UP A BIT
    free(polylineCoords);

    
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
    _totalDistanceLabel.text = [_walkRouteInfo objectForKey:@"Distance"];
    
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
    _totalTimeLabel.text = [_walkRouteInfo objectForKey:@"Time"];
    
    [self.view addSubview:_totalDistanceLabel];
    [self.view addSubview:_totalTimeLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor redColor];
    polylineView.lineWidth = 10.0;
    
    return polylineView;
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
