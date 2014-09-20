//
//  ResetPasswordSection.m
//  Handshake
//
//  Created by Sam Ober on 9/10/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "ResetPasswordSection.h"
#import "ResetPasswordTableViewCell.h"

@interface ResetPasswordSection()

@property (nonatomic, strong) ResetPasswordTableViewCell *resetPasswordCell;

@end

@implementation ResetPasswordSection

- (ResetPasswordTableViewCell *)resetPasswordCell {
    if (!_resetPasswordCell) {
        _resetPasswordCell = [[ResetPasswordTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    return _resetPasswordCell;
}

- (int)rows {
    return 1;
}

- (BaseTableViewCell *)cellForRow:(int)row indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    return self.resetPasswordCell;
}

@end
