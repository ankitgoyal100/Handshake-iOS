//
//  BaseTableViewController.h
//  Handshake
//
//  Created by Sam Ober on 9/8/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"
#import "MessageTableViewCell.h"

@interface BaseTableViewController : UIViewController

- (int)numberOfSections;
- (int)numberOfRowsInSection:(int)section;

- (BaseTableViewCell *)cellAtRow:(int)row section:(int)section indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView;

- (void)cellWasSelectedAtRow:(int)row section:(int)section indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView;

- (NSIndexPath *)indexPathForCell:(BaseTableViewCell *)cell;
- (BaseTableViewCell *)cellForRow:(int)row section:(int)section;

- (NSIndexPath *)indexPathForRow:(int)row section:(int)section;

- (void)scrolled:(UIScrollView *)scrollView;

- (void)insertRowAtRow:(int)row section:(int)section;
- (void)removeRowAtRow:(int)row section:(int)section;

- (void)insertRowAtRow:(int)row section:(int)section animation:(UITableViewRowAnimation)animation;
- (void)removeRowAtRow:(int)row section:(int)section animation:(UITableViewRowAnimation)animation;

- (void)moveCellAtRow:(int)row toRow:(int)toRow section:(int)section;

@property (nonatomic, readonly, strong) UITableView *tableView;

@property (nonatomic, strong) MessageTableViewCell *messageCell;
@property (nonatomic, strong) BaseTableViewCell *endCell;

@property (nonatomic) BOOL loading;

@end
