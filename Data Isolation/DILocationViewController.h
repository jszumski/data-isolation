//
//  DILocationViewController.h
//  Data Isolation
//
//  Created by John Szumski.
//  Copyright (c) 2012 CapTech Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface DILocationViewController : UIViewController <CLLocationManagerDelegate>

@property(nonatomic,strong) IBOutlet UIImageView				*statusIcon;
@property(nonatomic,strong) IBOutlet UILabel					*statusLabel;

@property(nonatomic,strong) IBOutlet UIButton					*locateMeButton;
@property(nonatomic,strong) IBOutlet UILabel					*coordinatesLabel;
@property(nonatomic,strong) IBOutlet UILabel					*accuracyLabel;
@property(nonatomic,strong) IBOutlet UIActivityIndicatorView	*spinner;

@end