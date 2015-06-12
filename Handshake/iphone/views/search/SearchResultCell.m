//
//  SearchResultCell.m
//  Handshake
//
//  Created by Sam Ober on 5/11/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "SearchResultCell.h"
#import "UIControl+Blocks.h"
#import "HandshakeClient.h"
#import "HandshakeSession.h"
#import "HandshakeCoreDataStore.h"
#import "RequestServerSync.h"

@implementation SearchResultCell

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
    
    if ([user.mutual intValue] == 1)
        self.mutualLabel.text = @"1 mutual contact";
    else
        self.mutualLabel.text = [NSString stringWithFormat:@"%d mutual contacts", [user.mutual intValue]];
    
    if ([user.requestSent boolValue]) {
        self.sentButton.hidden = NO;
        self.sendButton.hidden = YES;
    } else {
        self.sentButton.hidden = YES;
        self.sendButton.hidden = NO;
    }
    
    [self.sentButton addEventHandler:^(id sender) {
        if (![user.requestSent boolValue]) return;
        
        self.sentButton.hidden = YES;
        self.sendButton.hidden = NO;
        
        [RequestServerSync deleteRequest:user successBlock:^(User *user) {
            // do nothing
        } failedBlock:^{
            // reset cell
            self.user = self.user;
        }];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.sendButton addEventHandler:^(id sender) {
        if ([user.requestSent boolValue]) return;
        
        self.sentButton.hidden = NO;
        self.sendButton.hidden = YES;
        
        [RequestServerSync sendRequest:user successBlock:^(User *user) {
            // do nothing
        } failedBlock:^{
            // reset cell
            self.user = self.user;
        }];
    } forControlEvents:UIControlEventTouchUpInside];
}

@end
