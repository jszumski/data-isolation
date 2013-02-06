//
//  DIPhotosViewController.h
//  Data Isolation
//
//  Created by John Szumski.
//  Copyright (c) 2012 CapTech Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DITableViewController.h"

@interface DIPhotosViewController : DITableViewController

@property(nonatomic,strong) NSArray *photos;

@end