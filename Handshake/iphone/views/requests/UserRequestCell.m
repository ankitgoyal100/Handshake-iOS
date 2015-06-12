//
//  UserRequestCell.m
//  Handshake
//
//  Created by Sam Ober on 5/9/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "UserRequestCell.h"
#import "UIControl+Blocks.h"
#import "RequestServerSync.h"

@implementation UserRequestCell

- (void)setUser:(User *)user {
    _user = user;
    
    self.pictureView.image = nil;
    self.pictureView.imageURL = nil;
    if ([user cachedThumb])
        self.pictureView.image = [user cachedThumb];
    else if (user.thumb)
        self.pictureView.imageURL = [NSURL URLWithString:user.thumb];
    else
        self.pictureView.image = [UIImage imageNamed:@"default_picture"];
    
    self.nameLabel.text = [user formattedName];
    
    self.acceptButton.hidden = YES;
    self.declineButton.hidden = YES;
    if ([user.isContact boolValue]) {
        self.mutualFriendsLabel.text = @"Request accepted";
    } else if (![user.requestReceived boolValue]) {
        self.mutualFriendsLabel.text = @"Request declined";
    } else {
        if ([user.mutual intValue] == 1)
            self.mutualFriendsLabel.text = @"1 mutual contact";
        else
            self.mutualFriendsLabel.text = [NSString stringWithFormat:@"%d mutual contacts", [user.mutual intValue]];
        
        self.acceptButton.hidden = NO;
        self.declineButton.hidden = NO;
    }
    
    [self.acceptButton addEventHandler:^(id sender) {
        self.acceptButton.hidden = YES;
        self.declineButton.hidden = YES;
        
        self.mutualFriendsLabel.text = @"Request accepted";
        
        [RequestServerSync acceptRequest:user successBlock:^(User *user) {
            // do nothing
        } failedBlock:^{
            self.user = self.user;
            
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not accept request at this time. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.declineButton addEventHandler:^(id sender) {
        self.acceptButton.hidden = YES;
        self.declineButton.hidden = YES;
        
        self.mutualFriendsLabel.text = @"Request declined";
        
        [RequestServerSync declineRequest:user successBlock:^(User *user) {
            // do nothing
        } failedBlock:^{
            self.user = self.user;
            
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not decline request at this time. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    } forControlEvents:UIControlEventTouchUpInside];
}

@end
