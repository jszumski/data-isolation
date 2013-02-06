//
//  DIContactsViewController.m
//  Data Isolation
//
//  Created by John Szumski.
//  Copyright (c) 2012 CapTech Consulting. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import "DIContactsViewController.h"


@implementation DIContactsViewController {
	ABAddressBookRef	addressBook;
	NSMutableArray		*contacts;
}

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
	
    if (self) {
		self.title = @"Contacts";
		self.tabBarItem.image = [UIImage imageNamed:@"tab_contacts"];
		
		addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
		contacts = [NSMutableArray array];
		
		self.emptyMessage = @"";
		self.emptyMessageAuthorized = @"No contacts";
		self.emptyMessageDenied = @"Contacts unavailable";
		self.emptyMessagePending = @"Waiting...";
    }
	
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
	DIContactsViewController * __weak weakSelf = self; // avoid capturing self in the block

	ABAddressBookRequestAccessCompletionHandler completion = ^(bool granted, CFErrorRef error) {															   if (granted) {
			[weakSelf fetchContactsAndUpdate];
		
		} else {
			// update the UI on the main thread
			dispatch_async(dispatch_get_main_queue(), ^{
				[contacts removeAllObjects];
				[self.tableView reloadData];
			});
		}
		
		[self updateStatusDisplayForStatus:ABAddressBookGetAuthorizationStatus()];
	};
	
	
	// ask the user for access if necessary
	switch (status) {
		case kABAuthorizationStatusNotDetermined:
			ABAddressBookRequestAccessWithCompletion(addressBook,completion);
			self.emptyMessage = self.emptyMessagePending;
			break;
			
		case kABAuthorizationStatusAuthorized:
			self.emptyMessage = self.emptyMessageAuthorized;
			completion(YES, NULL);
			break;

		case kABAuthorizationStatusDenied:
		case kABAuthorizationStatusRestricted:
			self.emptyMessage = self.emptyMessageDenied;
			completion(NO, NULL);
			break;
	}
	
	[self updateStatusDisplayForStatus:status];
}


#pragma mark - Utils

- (void)fetchContactsAndUpdate {
	/* 
	 * addressBook must always be called on the same thread it was created on
	 * it's the main thread for this example, but should probably be on its own background thread in production code
	 */
	dispatch_async(dispatch_get_main_queue(), ^{
		CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
		CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(kCFAllocatorDefault,
																   CFArrayGetCount(people),
																   people);
		
		CFArraySortValues(peopleMutable,
						  CFRangeMake(0, CFArrayGetCount(peopleMutable)),
						  (CFComparatorFunction)ABPersonComparePeopleByName,
						  (void*)ABPersonGetSortOrdering());
				
		// clear any existing people
		[contacts removeAllObjects];
		
		// add the new people
		for (id record in (__bridge NSArray*)peopleMutable) {
			NSString* compositeName = (NSString *)CFBridgingRelease(ABRecordCopyCompositeName((__bridge ABRecordRef)record));
			
			[contacts addObject:compositeName];
		}
		
		// update the UI
		[self.tableView reloadData];
		
		CFRelease(people);
		CFRelease(peopleMutable);
	});
}

- (void)updateStatusDisplayForStatus:(ABAuthorizationStatus)status {
	dispatch_async(dispatch_get_main_queue(), ^{
		switch (status) {
			case kABAuthorizationStatusAuthorized:
				self.statusIcon.image = [UIImage imageNamed:@"icon_green"];
				self.statusLabel.text = @"Authorized";
				break;
				
			case kABAuthorizationStatusDenied:
				self.statusIcon.image = [UIImage imageNamed:@"icon_red"];
				self.statusLabel.text = @"Denied";
				break;
				
			case kABAuthorizationStatusRestricted:
				self.statusIcon.image = [UIImage imageNamed:@"icon_red"];
				self.statusLabel.text = @"Restricted";
				break;
				
			case kABAuthorizationStatusNotDetermined:
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


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([contacts count] == 0) {
		return 4;
		
	} else {
		return [contacts count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	// show real contacts
	if ([contacts count] != 0) {
		static NSString *contactCellId = @"contactCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contactCellId];
		
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contactCellId];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		cell.textLabel.text = [contacts objectAtIndex:indexPath.row];
		
		return cell;
	
	// show our empty message
	} else if ([contacts count] == 0 && indexPath.row == 3) {
		return [super tableView:tableView cellForRowAtIndexPath:indexPath];
	}
	
	return [[UITableViewCell alloc] init];
}

@end