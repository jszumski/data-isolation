//
//  DIAppDelegate.m
//  Data Isolation
//
//  Created by John Szumski.
//  Copyright (c) 2012 CapTech Consulting. All rights reserved.
//

#import "DIAppDelegate.h"
#import "DILocationViewController.h"
#import "DIContactsViewController.h"
#import "DICalendarViewController.h"
#import "DIRemindersViewController.h"
#import "DIPhotosViewController.h"

@implementation DIAppDelegate {
	NSInteger lastSelectedTab;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	UINavigationController *locationNav = [[UINavigationController alloc] initWithRootViewController:[[DILocationViewController alloc] init]];
	UINavigationController *contactsNav = [[UINavigationController alloc] initWithRootViewController:[[DIContactsViewController alloc] init]];
	UINavigationController *calendarNav = [[UINavigationController alloc] initWithRootViewController:[[DICalendarViewController alloc] init]];
	UINavigationController *remindersNav = [[UINavigationController alloc] initWithRootViewController:[[DIRemindersViewController alloc] init]];
	UINavigationController *photosNav = [[UINavigationController alloc] initWithRootViewController:[[DIPhotosViewController alloc] init]];
	
	self.tabBarController = [[UITabBarController alloc] init];
	self.tabBarController.viewControllers = @[locationNav, contactsNav, calendarNav, remindersNav, photosNav];
	
	self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
	
	// add KVO for state restoration
	[self.tabBarController addObserver:self forKeyPath:@"selectedViewController" options:NSKeyValueObservingOptionNew context:nil];
	
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// restore state
	lastSelectedTab = [[NSUserDefaults standardUserDefaults] integerForKey:@"tabBarControllerSelectedTab"];
	self.tabBarController.selectedIndex = lastSelectedTab;
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// clean up KVO
	[self.tabBarController removeObserver:self forKeyPath:@"selectedViewController"];
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == self.tabBarController && [keyPath isEqualToString:@"selectedViewController"]) {
		// update the saved state
		[[NSUserDefaults standardUserDefaults] setInteger:self.tabBarController.selectedIndex forKey:@"tabBarControllerSelectedTab"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

@end