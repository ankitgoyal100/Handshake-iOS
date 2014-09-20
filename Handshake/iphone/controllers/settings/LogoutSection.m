//
//  LogoutSection.m
//  Handshake
//
//  Created by Sam Ober on 9/10/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "LogoutSection.h"
#import "LogoutTableViewCell.h"
#import "HandshakeSession.h"
#import "Handshake.h"

@interface LogoutSection() <UIAlertViewDelegate>

@property (nonatomic, strong) LogoutTableViewCell *logoutCell;

@end

@implementation LogoutSection

- (LogoutTableViewCell *)logoutCell {
    if (!_logoutCell) {
        _logoutCell = [[LogoutTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    return _logoutCell;
}

- (int)rows {
    return 1;
}

- (BaseTableViewCell *)cellForRow:(int)row indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    return self.logoutCell;
}

- (void)cellWasSelectedAtRow:(int)row indexPath:(NSIndexPath *)indexPath {
    [[[UIAlertView alloc] initWithTitle:@"Logout" message:@"Are you sure you want to logout?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Logout", nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Logout"]) {
        [HandshakeSession logout];
    }
}

@end
