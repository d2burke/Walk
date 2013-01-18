//
//  ViewController.h
//  Walk
//
//  Created by Daniel Burke on 1/17/13.
//  Copyright (c) 2013 Daniel Burke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIView *navContainer;
@property (strong, nonatomic) UIButton *navLogo;



@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) IBOutlet MKMapView *map;
@property (strong, nonatomic) MKPolyline *routeLine;
@property (nonatomic, strong) UIView *containerView;
@property (strong, nonatomic) NSMutableArray *points;
@property (strong, nonatomic) NSMutableArray *pointsDistances;
@property (nonatomic) double totalDistance;
@property (strong, nonatomic) UILabel *totalDistanceLabel;
@property (strong, nonatomic) UIScrollView *snapShots;
@property (nonatomic) int numSnapShots;
@property (strong, nonatomic) NSTimer *walkRouteTimer;
@property (strong, nonatomic) NSString *totalTime;
@property (strong, nonatomic) UILabel *totalTimeLabel;
@property (strong, nonatomic) NSDate *startTime;

@property (nonatomic) double maxLat;
@property (nonatomic) double minLat;

@property (nonatomic) double maxLong;
@property (nonatomic) double minLong;

@property (strong, nonatomic) UIButton *endWalkBtn;
@property (strong, nonatomic) UIButton *startWalkBtn;
@property (strong, nonatomic) UIButton *resetBtn;


- (void)switchToBackgroundMode:(BOOL)background;

@end
