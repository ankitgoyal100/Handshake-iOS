//
//  ResetPasswordSection.m
//  Handshake
//
//  Created by Sam Ober on 9/10/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "ResetPasswordSection.h"
#import "ResetPasswordTableViewCell.h"
#import "HandshakeClient.h"
#import "HandshakeSession.h"
#import "User.h"

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

- (void)cellWasSelectedAtRow:(int)row indexPath:(NSIndexPath *)indexPath {
    if (self.resetPasswordCell.loading) return;
    
    self.resetPasswordCell.loading = YES;
    User *user = [HandshakeSession user];
    [[HandshakeClient client] POST:@"/password" parameters:@{ @"user":@{ @"email":user.email } } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.resetPasswordCell.loading = NO;
        [[[UIAlertView alloc] initWithTitle:@"Reset Instructions Sent" message:@"You should receive an email shorty." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.resetPasswordCell.loading = NO;
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not reset password. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

@end
