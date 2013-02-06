//
//  DIRemindersViewController.m
//  Data Isolation
//
//  Created by John Szumski.
//  Copyright (c) 2012 CapTech Consulting. All rights reserved.
//

#import "DIRemindersViewController.h"

@implementation DIRemindersViewController

- (id)init {
    self = [super init];
	
    if (self) {
		self.title = @"Reminders";
		self.tabBarItem.image = [UIImage imageNamed:@"tab_reminders"];
		
		self.displayedType = EKEntityTypeReminder;
		
		self.emptyMessageAuthorized = @"No reminders";
		self.emptyMessageDenied = @"Reminders unavailable";
		self.emptyMessagePending = @"Waiting...";
    }
	
    return self;
}

@end