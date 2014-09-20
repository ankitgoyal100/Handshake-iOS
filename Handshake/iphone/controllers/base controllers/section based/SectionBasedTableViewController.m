//
//  SectionBasedTableViewController.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "SectionBasedTableViewController.h"
#import "Section.h"

@implementation SectionBasedTableViewController

- (NSMutableArray *)sections {
    if (!_sections) _sections = [[NSMutableArray alloc] init];
    return _sections;
}

- (int)numberOfSections {
    int sections = 0;
    for (Section *section in self.sections) {
        if ([section rows] > 0) sections++;
        else if ([self.sections indexOfObject:section] == [self.sections count] - 1) sections++;
    }
    return sections;
}

- (int)numberOfRowsInSection:(int)section {
    int currSection = 0;
    for (int i = 0; i < [self.sections count]; i++) {
        int rows = [(Section *)self.sections[i] rows];
        if (rows > 0 && currSection++ == section)
            return rows;
    }
    return 0;
}

- (BaseTableViewCell *)cellAtRow:(int)row section:(int)section indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    int currSection = 0;
    for (int i = 0; i < [self.sections count]; i++) {
        int rows = [(Section *)self.sections[i] rows];
        if (rows > 0 && currSection++ == section)
            return [(Section *)self.sections[i] cellForRow:row indexPath:indexPath tableView:tableView];
    }
    return nil;
}

- (void)cellWasSelectedAtRow:(int)row section:(int)section indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    int currSection = 0;
    for (int i = 0; i < [self.sections count]; i++) {
        int rows = [(Section *)self.sections[i] rows];
        if (rows > 0 && currSection++ == section) {
            [(Section *)self.sections[i] cellWasSelectedAtRow:row indexPath:indexPath];
            return;
        }
    }
}

@end
