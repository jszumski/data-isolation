//
//  DICalendarViewController.h
//  Data Isolation
//
//  Created by John Szumski.
//  Copyright (c) 2012 CapTech Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import "DITableViewController.h"

@interface DICalendarViewController : DITableViewController

@property(nonatomic,assign) EKEntityType displayedType;

- (NSString*)subtitleForEvent:(EKEvent*)event;

@end