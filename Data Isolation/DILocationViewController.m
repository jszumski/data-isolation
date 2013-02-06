//
//  DILocationViewController.m
//  Data Isolation
//
//  Created by John Szumski.
//  Copyright (c) 2012 CapTech Consulting. All rights reserved.
//

#import "DILocationViewController.h"

@implementation DILocationViewController {
	CLLocationManager *locationManager;
}

- (id)init {
    self = [super initWithNibName:@"DILocationViewController" bundle:nil];
	
    if (self) {
		self.title = @"Location";
		self.tabBarItem.image = [UIImage imageNamed:@"tab_location"];
		
		// create the location manager
		locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
    }
	
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// set the intial status
	[self updateStatusDisplayForGlobalStatus:[CLLocationManager locationServicesEnabled]
								   appStatus:[CLLocationManager authorizationStatus]];
	
	// determine if we can enable locate me
	[self determineLocateMeState];
}


#pragma mark - UI response

- (IBAction)locateMeTapped:(id)sender {
	[locationManager startUpdatingLocation];
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	// get the most recent location
	CLLocation *location = [locations lastObject];
	
	// show the most recent coordinate
	self.coordinatesLabel.text = [NSString stringWithFormat:@"%2.4f, %2.4f",
									location.coordinate.latitude,
									location.coordinate.longitude
								  ];
	
	// determine the worst accuracy of the two dimensions and show it
	CLLocationAccuracy leastAccurateDimensionAccuracy = 0;
	if (location.horizontalAccuracy > location.verticalAccuracy) {
		leastAccurateDimensionAccuracy = location.horizontalAccuracy;
	} else {
		leastAccurateDimensionAccuracy = location.verticalAccuracy;
	}
	
	self.accuracyLabel.text = [NSString stringWithFormat:@"%.0f meters", leastAccurateDimensionAccuracy];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	// the user denied access
	if (error.code == kCLErrorDenied) {
		[manager stopUpdatingLocation];
		
		self.coordinatesLabel.text = @"Denied";
		self.accuracyLabel.text = @"Denied";
		
		self.locateMeButton.enabled = NO;
		
		
	// any other errors
	} else {
		self.coordinatesLabel.text = @"Unknown";
		self.accuracyLabel.text = @"Unknown";
	}
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	// update UI for the new status
	[self updateStatusDisplayForGlobalStatus:[CLLocationManager locationServicesEnabled]
								   appStatus:[CLLocationManager authorizationStatus]];
	
	[self determineLocateMeState];
}


#pragma mark - Utils

- (void)updateStatusDisplayForGlobalStatus:(BOOL)global appStatus:(CLAuthorizationStatus)status {
	if (global) {
		switch (status) {
			case kCLAuthorizationStatusAuthorized:
				self.statusIcon.image = [UIImage imageNamed:@"icon_green"];
				self.statusLabel.text = @"Authorized";
				break;
				
			case kCLAuthorizationStatusDenied:
				self.statusIcon.image = [UIImage imageNamed:@"icon_red"];
				self.statusLabel.text = @"Denied";
				break;
				
			case kCLAuthorizationStatusRestricted:
				self.statusIcon.image = [UIImage imageNamed:@"icon_red"];
				self.statusLabel.text = @"Restricted";
				break;
				
			case kCLAuthorizationStatusNotDetermined:
				self.statusIcon.image = [UIImage imageNamed:@"icon_grey"];
				self.statusLabel.text = @"Undetermined";
				break;
				
			default:
				self.statusIcon.image = [UIImage imageNamed:@"icon_grey"];
				self.statusLabel.text = @"Unknown";
				break;
		}
	
	} else {
		self.statusIcon.image = [UIImage imageNamed:@"icon_red"];
		self.statusLabel.text = @"Location Services Are Off";
	}
}

- (void)determineLocateMeState {
	if ([CLLocationManager locationServicesEnabled] == NO ||
		[CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
		[CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
		
		self.locateMeButton.enabled = NO;
		
	} else {
		self.locateMeButton.enabled = YES;
	}
}

@end