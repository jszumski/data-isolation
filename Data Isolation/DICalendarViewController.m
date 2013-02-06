//
//  DICalendarViewController.m
//  Data Isolation
//
//  Created by John Szumski.
//  Copyright (c) 2012 CapTech Consulting. All rights reserved.
//

#import "DICalendarViewController.h"

@implementation DICalendarViewController {
	EKEventStore	*eventStore;
	NSMutableArray	*events;
	NSDateFormatter	*dateFormatter;
}

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
	
    if (self) {
		self.title = @"Calendar";
		self.tabBarItem.image = [UIImage imageNamed:@"tab_calendar"];
		
		eventStore = [[EKEventStore alloc] init];
		events = [NSMutableArray array];
		self.displayedType = EKEntityTypeEvent;
		
		dateFormatter = [[NSDateFormatter alloc] init];
		dateFormatter.dateStyle = NSDateFormatterShortStyle;
		dateFormatter.timeStyle = NSDateFormatterShortStyle;
		
		self.emptyMessage = @"";
		self.emptyMessageAuthorized = @"No events";
		self.emptyMessageDenied = @"Events unavailable";
		self.emptyMessagePending = @"Waiting...";
    }
	
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:self.displayedType];
	DICalendarViewController * __weak weakSelf = self; // avoid capturing self in the block
	
	EKEventStoreRequestAccessCompletionHandler completion = ^(BOOL granted, NSError *error) {
		if (granted) {
			[weakSelf fetchEventsAndUpdate];
			
		} else {
			dispatch_async(dispatch_get_main_queue(), ^{
				[events removeAllObjects];
				[self.tableView reloadData];
			});
		}
		
		[self updateStatusDisplayForStatus:ABAddressBookGetAuthorizationStatus()];
	};
	
	
	// ask the user for access if necessary
	switch (status) {
		case EKAuthorizationStatusNotDetermined:
			[eventStore requestAccessToEntityType:self.displayedType completion:completion];
			self.emptyMessage = self.emptyMessagePending;
			break;
			
		case EKAuthorizationStatusAuthorized:
			self.emptyMessage = self.emptyMessageAuthorized;
			completion(YES, NULL);
			break;
			
		case EKAuthorizationStatusDenied:
		case EKAuthorizationStatusRestricted:
			self.emptyMessage = self.emptyMessageDenied;
			completion(NO, NULL);
			break;
	}
	
	[self updateStatusDisplayForStatus:status];
}


#pragma mark - Utils

- (void)updateStatusDisplayForStatus:(EKAuthorizationStatus)status {
	dispatch_async(dispatch_get_main_queue(), ^{
		switch (status) {
			case EKAuthorizationStatusAuthorized:
				self.statusIcon.image = [UIImage imageNamed:@"icon_green"];
				self.statusLabel.text = @"Authorized";
				break;
				
			case EKAuthorizationStatusDenied:
				self.statusIcon.image = [UIImage imageNamed:@"icon_red"];
				self.statusLabel.text = @"Denied";
				break;
				
			case EKAuthorizationStatusRestricted:
				self.statusIcon.image = [UIImage imageNamed:@"icon_red"];
				self.statusLabel.text = @"Restricted";
				break;
				
			case EKAuthorizationStatusNotDetermined:
				self.statusIcon.image = [UIImage imageNamed:@"icon_grey"];
				self.statusLabel.text = @"Undetermined";
				break;
				
			default:
				self.statusIcon.image = [UIImage imageNamed:@"icon_grey"];
				self.statusLabel.text = @"Unknown";
				break;
		}
	});
}

- (void)fetchEventsAndUpdate {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSArray *calendars = [eventStore calendarsForEntityType:self.displayedType];

		NSDate *aYearFromNow = [NSDate dateWithTimeIntervalSinceNow:60*60*24*30];
		NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:[NSDate date]
																	 endDate:aYearFromNow
																   calendars:calendars];
		NSArray *eventList = [eventStore eventsMatchingPredicate:predicate];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			// clear any existing events
			[events removeAllObjects];
			
			// show the new events
			[events addObjectsFromArray:eventList];
			[self.tableView reloadData];
		});
	});
}

- (NSString*)subtitleForEvent:(EKEvent*)event {
	return [NSString stringWithFormat:@"%@ to %@",
				[dateFormatter stringFromDate:event.startDate],
				[dateFormatter stringFromDate:event.endDate]
			];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([events count] == 0) {
		return 4;
		
	} else {
		return [events count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	// show real events
	if ([events count] != 0) {
		static NSString *contactCellId = @"contactCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contactCellId];
		
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:contactCellId];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		EKEvent *event = [events objectAtIndex:indexPath.row];
		
		cell.textLabel.text = event.title;
		cell.detailTextLabel.text = [self subtitleForEvent:event];
		
		return cell;
		
	// show our empty message
	} else if ([events count] == 0 && indexPath.row == 3) {
		return [super tableView:tableView cellForRowAtIndexPath:indexPath];
	}
	
	return [[UITableViewCell alloc] init];
}

@end