//
//  DIAppDelegate.h
//  Data Isolation
//
//  Created by John Szumski.
//  Copyright (c) 2012 CapTech Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DIAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

@end
