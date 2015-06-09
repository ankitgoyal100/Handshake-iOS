//
//  UserRequestCell.m
//  Handshake
//
//  Created by Sam Ober on 5/9/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "UserRequestCell.h"
#import "User.h"
#import "UIControl+Blocks.h"

@implementation UserRequestCell

- (void)setRequest:(Request *)request {
    _request = request;
    
    self.pictureView.image = nil;
    self.pictureView.imageURL = nil;
    if ([request.user cachedImage])
        self.pictureView.image = [request.user cachedImage];
    else if (request.user.picture)
        self.pictureView.imageURL = [NSURL URLWithString:request.user.picture];
    else
        self.pictureView.image = [UIImage imageNamed:@"default_picture"];
    
    self.nameLabel.text = [request.user formattedName];
    
    self.acceptButton.hidden = YES;
    self.declineButton.hidden = YES;
    if ([request.accepted boolValue]) {
        self.mutualFriendsLabel.text = @"Request accepted";
    } else if ([request.removed boolValue]) {
        self.mutualFriendsLabel.text = @"Request declined";
    } else {
        if ([request.user.mutual intValue] == 1)
            self.mutualFriendsLabel.text = @"1 mutual contact";
        else
            self.mutualFriendsLabel.text = [NSString stringWithFormat:@"%d mutual contacts", [request.user.mutual intValue]];
        
        self.acceptButton.hidden = NO;
        self.declineButton.hidden = NO;
    }
    
    [self.acceptButton addEventHandler:^(id sender) {
        self.acceptButton.hidden = YES;
        self.declineButton.hidden = YES;
        
        self.mutualFriendsLabel.text = @"Request accepted";
        
        [request acceptWithSuccessBlock:^(Contact *contact) {
            
        } failedBlock:^{
            self.request = request;
            
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not accept request at this time. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.declineButton addEventHandler:^(id sender) {
        self.acceptButton.hidden = YES;
        self.declineButton.hidden = YES;
        
        self.mutualFriendsLabel.text = @"Request declined";
        
        [request deleteWithSuccessBlock:^{
            
        } failedBlock:^{
            self.request = request;
            
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not decline request at this time. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    } forControlEvents:UIControlEventTouchUpInside];
}

@end
