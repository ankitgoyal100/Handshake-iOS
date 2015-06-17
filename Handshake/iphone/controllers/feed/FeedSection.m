//
//  FeedSection.m
//  Handshake
//
//  Created by Sam Ober on 6/16/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "FeedSection.h"

@implementation FeedSection

- (id)initWithViewController:(UITableViewController *)controller sectionIndex:(int)sectionIndex {
    self = [super init];
    if (self) {
        self.viewController = controller;
        self.sectionIndex = sectionIndex;
    }
    return self;
}

- (BOOL)hasHeader {
    return NO;
}

- (NSInteger)numberOfRows {
    return 0;
}

- (UITableViewCell *)cellAtIndex:(NSInteger)index inTableView:(UITableView *)tableView {
    return nil;
}

- (CGFloat)heightForCellAtIndex:(NSInteger)index {
    return 0;
}

- (void)cellWasSelectedAtIndex:(NSInteger)index {
    
}

@end
