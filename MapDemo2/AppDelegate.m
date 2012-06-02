//
//  AppDelegate.m
//  MapDemo2
//
//  Created by 俞 億 on 12-5-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MapRootController.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    MapRootController *mapRootController = [[MapRootController alloc]init];
    UINavigationController *nav =[[UINavigationController alloc]initWithRootViewController:mapRootController];
    self.window.rootViewController = nav;
    [nav release];
    [mapRootController release];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}
@end
