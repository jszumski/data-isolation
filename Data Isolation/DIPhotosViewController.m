//
//  DIPhotosViewController.m
//  Data Isolation
//
//  Created by John Szumski.
//  Copyright (c) 2012 CapTech Consulting. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "DIPhotosViewController.h"

#define kAssetImageKey @"imageKey"
#define kAssetNameKey @"nameKey"

@implementation DIPhotosViewController {
	ALAssetsLibrary						*assetLibrary;
	ALAssetsLibraryAccessFailureBlock	failureBlock;
}

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
	
    if (self) {
		self.title = @"Photos";
		self.tabBarItem.image = [UIImage imageNamed:@"tab_photos"];
		
		self.photos = [NSArray array];
		assetLibrary = [[ALAssetsLibrary alloc] init];
		
		self.emptyMessage = @"";
		self.emptyMessageAuthorized = @"No photos";
		self.emptyMessageDenied = @"Photos unavailable";
		self.emptyMessagePending = @"Waiting...";
		
		// this block needs to be at this scope because it is used in viewDidAppear and fetchPhotosAndUpdate
		DIPhotosViewController * __weak weakSelf = self; // avoid capturing self in the block
		failureBlock = ^(NSError* error) {
			weakSelf.photos = [NSArray array];
			[weakSelf.tableView reloadData];
			
			[weakSelf updateStatusDisplayForStatus:[ALAssetsLibrary authorizationStatus]];
		};
    }
	
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
	
	// ask the user for access if necessary
	switch (status) {
		case ALAuthorizationStatusNotDetermined:
			self.emptyMessage = self.emptyMessagePending;
			[self fetchPhotosAndUpdate];
			break;
			
		case ALAuthorizationStatusAuthorized:
			self.emptyMessage = self.emptyMessageAuthorized;
			[self fetchPhotosAndUpdate];
			break;
			
		case ALAuthorizationStatusDenied:
		case ALAuthorizationStatusRestricted:
			self.emptyMessage = self.emptyMessageDenied;
			failureBlock(nil);
			break;
	}
	
	[self updateStatusDisplayForStatus:status];
}


#pragma mark - Utils

- (void)fetchPhotosAndUpdate {
	DIPhotosViewController * __weak weakSelf = self; // avoid capturing self in the block
	
	ALAssetsLibraryGroupsEnumerationResultsBlock groupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
		// we only need to update the status UI once
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			[weakSelf updateStatusDisplayForStatus:[ALAssetsLibrary authorizationStatus]];
		});

		NSMutableArray *photos = [NSMutableArray array];
		
		// only use the first group we find
		if (group != nil) {
			*stop = YES;
		}
		
		[group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {			
			// check for more results
			if (result != nil) {
				UIImage *thumb = [UIImage imageWithCGImage:[result thumbnail]
													 scale:[UIScreen mainScreen].scale
											   orientation:UIImageOrientationUp];
				
				NSString *name = [[result defaultRepresentation] filename];
				
				[photos addObject:[NSDictionary dictionaryWithObjectsAndKeys:
									   thumb, kAssetImageKey,
									   name, kAssetNameKey,
								   nil]];
			
			// we're at the end, so update the UI
			} else {
				dispatch_async(dispatch_get_main_queue(), ^{
					[weakSelf setPhotos:photos];
					[self.tableView reloadData];
				});
			}
		}];
	};
	
	[assetLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
								usingBlock:groupBlock
							  failureBlock:failureBlock];
}

- (void)updateStatusDisplayForStatus:(ALAuthorizationStatus)status {
	dispatch_async(dispatch_get_main_queue(), ^{
		switch (status) {
			case ALAuthorizationStatusAuthorized:
				self.statusIcon.image = [UIImage imageNamed:@"icon_green"];
				self.statusLabel.text = @"Authorized";
				break;
				
			case ALAuthorizationStatusDenied:
				self.statusIcon.image = [UIImage imageNamed:@"icon_red"];
				self.statusLabel.text = @"Denied";
				break;
				
			case ALAuthorizationStatusRestricted:
				self.statusIcon.image = [UIImage imageNamed:@"icon_red"];
				self.statusLabel.text = @"Restricted";
				break;
				
			case ALAuthorizationStatusNotDetermined:
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
	if ([self.photos count] == 0) {
		return 4;
		
	} else {
		return [self.photos count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	// show real photos
	if ([self.photos count] != 0) {
		static NSString *contactCellId = @"contactCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contactCellId];
		
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contactCellId];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		NSDictionary *assetInfo = [self.photos objectAtIndex:indexPath.row];
		
		if (assetInfo != nil && [assetInfo isKindOfClass:[NSDictionary class]]) {
			cell.textLabel.text = [assetInfo objectForKey:kAssetNameKey];
			cell.imageView.image = [assetInfo objectForKey:kAssetImageKey];
			
		} else {
			cell.textLabel.text = @"";
			cell.imageView.image = nil;
		}

		return cell;
		
	// show our empty message
	} else if ([self.photos count] == 0 && indexPath.row == 3) {
		return [super tableView:tableView cellForRowAtIndexPath:indexPath];
	}
	
	return [[UITableViewCell alloc] init];
}

@end