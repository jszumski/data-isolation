//
//  DITableViewController.h
//  Data Isolation
//
//  Created by John Szumski.
//  Copyright (c) 2012 CapTech Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DITableViewController : UITableViewController

@property(nonatomic,strong,readonly) UIView			*statusContainer;
@property(nonatomic,strong,readonly) UIImageView	*statusIcon;
@property(nonatomic,strong,readonly) UILabel		*statusLabel;

@property(nonatomic,strong)			 NSString		*emptyMessage;
@property(nonatomic,strong)			 NSString		*emptyMessageAuthorized;
@property(nonatomic,strong)			 NSString		*emptyMessageDenied;
@property(nonatomic,strong)			 NSString		*emptyMessagePending;

@end