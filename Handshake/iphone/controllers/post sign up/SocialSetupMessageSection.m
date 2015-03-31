//
//  SocialSetupMessageSection.m
//  Handshake
//
//  Created by Sam Ober on 10/6/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "SocialSetupMessageSection.h"
#import "SetupMessageTableViewCell.h"

@interface SocialSetupMessageSection()

@property (nonatomic, strong) SetupMessageTableViewCell *messageCell;

@end

@implementation SocialSetupMessageSection

- (SetupMessageTableViewCell *)messageCell {
    if (!_messageCell) {
        _messageCell = [[SetupMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        _messageCell.message = @"Log in to your social networks to connect with people faster!";
    }
    return _messageCell;
}

- (int)rows {
    return 1;
}

- (BaseTableViewCell *)cellForRow:(int)row indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    return self.messageCell;
}

@end
