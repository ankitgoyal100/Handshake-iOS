//
//  FeedSection.h
//  Handshake
//
//  Created by Sam Ober on 6/16/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FeedSection : NSObject

@property (nonatomic, strong) UITableViewController *viewController;
@property (nonatomic, readonly) BOOL hasHeader;
@property (nonatomic) int sectionIndex;

- (id)initWithViewController:(UITableViewController *)controller sectionIndex:(int)sectionIndex;

- (NSInteger)numberOfRows;
- (UITableViewCell *)cellAtIndex:(NSInteger)index inTableView:(UITableView *)tableView;

- (CGFloat)heightForCellAtIndex:(NSInteger)index;

- (void)cellWasSelectedAtIndex:(NSInteger)index;

@end
