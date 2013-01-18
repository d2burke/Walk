//
//  WalkRouteViewController.h
//  Walk
//
//  Created by Daniel Burke on 1/17/13.
//  Copyright (c) 2013 Daniel Burke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface WalkRouteViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIView *navContainer;
@property (strong, nonatomic) UIButton *navLogo;

@property (nonatomic, strong) IBOutlet MKMapView *map;
@property (strong, nonatomic) MKPolyline *routeLine;
@property (strong, nonatomic) NSDictionary *walkRouteInfo;
@property (strong, nonatomic) UIImage *walkRouteImage;

@property (strong, nonatomic) UILabel *totalDistanceLabel;
@property (strong, nonatomic) UILabel *totalTimeLabel;

@end
