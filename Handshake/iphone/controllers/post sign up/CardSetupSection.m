//
//  CardSetupSection.m
//  Handshake
//
//  Created by Sam Ober on 10/6/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "CardSetupSection.h"
#import "SetupMessageTableViewCell.h"

@interface CardSetupSection()

@property (nonatomic, strong) SetupMessageTableViewCell *messageCell;

@end

@implementation CardSetupSection

- (SetupMessageTableViewCell *)messageCell {
    if (!_messageCell) {
        _messageCell = [[SetupMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        _messageCell.message = @"Cards are what you send to all the people you meet. Create a new one to get started...";
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
