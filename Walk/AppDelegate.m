//
//  AppDelegate.m
//  Walk
//
//  Created by Daniel Burke on 1/17/13.
//  Copyright (c) 2013 Daniel Burke. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()
@property (nonatomic, strong) IBOutlet UINavigationController *navController;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[ViewController alloc] init];
    
    _navController =[[UINavigationController alloc] init];
    [_navController pushViewController:self.viewController animated:NO];

    self.window.rootViewController = _navController;
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // inform our view controller we are entering the background
    ViewController *mainViewController = (ViewController *)self.viewController;
    [mainViewController switchToBackgroundMode:YES];
}

-(void)applicationWillEnterForeground:(UIApplication *)application{

    // inform our view controller we are entering the background
    ViewController *mainViewController = (ViewController *)self.viewController;
    [mainViewController switchToBackgroundMode:NO];
}

@end
