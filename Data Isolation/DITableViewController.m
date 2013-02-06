//
//  DITableViewController.m
//  Data Isolation
//
//  Created by John Szumski.
//  Copyright (c) 2012 CapTech Consulting. All rights reserved.
//

#import "DITableViewController.h"

@interface DITableViewController ()

@property(nonatomic,strong,readwrite) UIView			*statusContainer;
@property(nonatomic,strong,readwrite) UIImageView	*statusIcon;
@property(nonatomic,strong,readwrite) UILabel		*statusLabel;

@end

@implementation DITableViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.tableView.showsVerticalScrollIndicator = NO;
	
	// create the status UI
	self.statusContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
	self.statusContainer.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
	
	self.statusIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_grey"]];
	self.statusIcon.frame = CGRectMake(16, 17, self.statusIcon.frame.size.width, self.statusIcon.frame.size.height);
	[self.statusContainer addSubview:self.statusIcon];
	
	self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.statusIcon.frame)+10,
																 12,
																 self.tableView.frame.size.width-CGRectGetMaxX(self.statusIcon.frame)-10,
																 20)];
	self.statusLabel.backgroundColor = [UIColor clearColor];
	
	UIView *border = [[UIView alloc] initWithFrame:CGRectMake(0,
															  CGRectGetMaxY(self.statusContainer.bounds)-1,
															  self.statusContainer.bounds.size.width,
															  1)];
	border.backgroundColor = self.tableView.separatorColor;
	[self.statusContainer addSubview:border];
	
	[self.statusContainer addSubview:self.statusLabel];
	
	
	// scroll guard
	UIView *scrollBackground = [[UIView alloc] initWithFrame:CGRectMake(0,
																		-self.tableView.frame.size.height,
																		self.tableView.frame.size.width,
																		self.tableView.frame.size.height)];
	scrollBackground.backgroundColor = self.statusContainer.backgroundColor;
	
	[self.tableView addSubview:scrollBackground];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return self.statusContainer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return self.statusContainer.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *emptyCellId = @"emptyCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:emptyCellId];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:emptyCellId];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.textAlignment = NSTextAlignmentCenter;
		cell.textLabel.textColor = [UIColor grayColor];
	}
	
	cell.textLabel.text = self.emptyMessage;
	
	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

@end