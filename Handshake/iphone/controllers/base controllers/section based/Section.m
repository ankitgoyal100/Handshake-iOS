//
//  Section.m
//  Handshake
//
//  Created by Sam Ober on 2/6/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "Section.h"

@implementation Section

- (id)initWithViewController:(SectionBasedTableViewController *)controller {
    self = [super init];
    if (self) {
        self.viewController = controller;
    }
    return self;
}

- (int)rows {
    return 0;
}

- (UITableViewCell *)cellForRow:(int)row indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    return nil;
}

- (float)heightForCellAtRow:(int)row {
    return 0;
}

- (void)cellWasSelectedAtRow:(int)row indexPath:(NSIndexPath *)indexPath {
    
}

- (void)removeRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    [tableView deleteRowsAtIndexPaths:@[indexPath, [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationTop];
}

- (void)insertRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    [tableView insertRowsAtIndexPaths:@[indexPath, [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationTop];
}

- (void)insertRowAtRow:(int)row {
    [self.viewController insertRowAtRow:row section:(int)[self.viewController.sections indexOfObject:self]];
}

- (void)removeRowAtRow:(int)row {
    [self.viewController removeRowAtRow:row section:(int)[self.viewController.sections indexOfObject:self]];
}

@end
