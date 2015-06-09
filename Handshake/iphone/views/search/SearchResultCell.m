//
//  SearchResultCell.m
//  Handshake
//
//  Created by Sam Ober on 5/11/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "SearchResultCell.h"
#import "UIControl+Blocks.h"
#import "User.h"
#import "Request.h"
#import "HandshakeClient.h"
#import "HandshakeSession.h"
#import "HandshakeCoreDataStore.h"

@implementation SearchResultCell

- (void)setResult:(SearchResult *)result {
    _result = result;
    
    self.pictureView.image = nil;
    self.pictureView.imageURL = nil;
    if ([result.user cachedImage])
        self.pictureView.image = [result.user cachedImage];
    else if (result.user.picture)
        self.pictureView.imageURL = [NSURL URLWithString:result.user.picture];
    else
        self.pictureView.image = [UIImage imageNamed:@"default_picture"];
    
    self.nameLabel.text = [result.user formattedName];
    
    if ([result.user.mutual intValue] == 1)
        self.mutualLabel.text = @"1 mutual contact";
    else
        self.mutualLabel.text = [NSString stringWithFormat:@"%d mutual contacts", [result.user.mutual intValue]];
    
    if (result.request) {
        self.sentButton.hidden = NO;
        self.sendButton.hidden = YES;
    } else {
        self.sentButton.hidden = YES;
        self.sendButton.hidden = NO;
    }
    
    [self.sentButton addEventHandler:^(id sender) {
        if (!result.request || !result.request.requestId) return;
        
        self.sentButton.hidden = YES;
        self.sendButton.hidden = NO;
        
        __block Request *oldRequest = result.request;
        
        [result.request deleteWithSuccessBlock:^{
            [result.managedObjectContext deleteObject:oldRequest];
        } failedBlock:^{
            result.request = oldRequest;
            self.result = result;
        }];
        
        result.request = nil;
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.sendButton addEventHandler:^(id sender) {
        if (result.request) return;
        
        self.sentButton.hidden = NO;
        self.sendButton.hidden = YES;
        
        result.request = [[Request alloc] initWithEntity:[NSEntityDescription entityForName:@"Request" inManagedObjectContext:result.managedObjectContext] insertIntoManagedObjectContext:result.managedObjectContext];
        result.request.user = [[HandshakeSession currentSession] account];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[HandshakeSession currentSession] credentials]];
        params[@"recipient_id"] = result.user.userId;
        params[@"card_ids"] = @[((Card *)[[HandshakeSession currentSession] account].cards[0]).cardId];
        [[HandshakeClient client] POST:@"/requests" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [result.request updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:responseObject[@"request"]]];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([[operation response] statusCode] == 401)
                [[HandshakeSession currentSession] invalidate];
            else {
                result.request = nil;
                self.result = result;
            }
        }];
    } forControlEvents:UIControlEventTouchUpInside];
}

@end
