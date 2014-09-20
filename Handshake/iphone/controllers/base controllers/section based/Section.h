//
//  Section.h
//  Handshake
//
//  Created by Sam Ober on 2/6/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "BaseTableViewCell.h"
#import "SectionBasedTableViewController.h"

@interface Section : NSObject

- (id)initWithViewController:(SectionBasedTableViewController *)controller;

- (int)rows;

- (BaseTableViewCell *)cellForRow:(int)row indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView;
- (float)heightForCellAtRow:(int)row;

- (void)cellWasSelectedAtRow:(int)row indexPath:(NSIndexPath *)indexPath;

- (void)removeRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView;
- (void)insertRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView;

- (void)insertRowAtRow:(int)row;
- (void)removeRowAtRow:(int)row;

@property (nonatomic) SectionBasedTableViewController *viewController;

@end
