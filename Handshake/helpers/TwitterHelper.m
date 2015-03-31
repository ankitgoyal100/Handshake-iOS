//
//  TwitterHelper.m
//  Handshake
//
//  Created by Sam Ober on 9/23/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "TwitterHelper.h"
#import "STTwitter.h"
#import <Accounts/Accounts.h>
#import <UIKit/UIKit.h>

@interface TwitterHelper() <UIActionSheetDelegate>

@property (nonatomic, strong) STTwitterAPI *twitterAPI;

@property (nonatomic, strong) NSString *username;

@property (nonatomic, strong) NSArray *accounts;

@property (nonatomic, copy) LoginSuccessBlock successBlock;

@end

@implementation TwitterHelper

+ (TwitterHelper *)sharedHelper {
    static TwitterHelper *sharedHelper = nil;
    if (!sharedHelper) sharedHelper = [[TwitterHelper alloc] init];
    return sharedHelper;
}

- (id)init {
    self = [super init];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *accountIdentifier = [defaults objectForKey:@"twitter_account"];
        
        if (accountIdentifier) {
            ACAccountStore *store = [[ACAccountStore alloc] init];
            ACAccount *account = [store accountWithIdentifier:accountIdentifier];
            
            if (account) {
                self.twitterAPI = [STTwitterAPI twitterAPIOSWithAccount:account];
                self.username = account.username;
            }
        }
    }
    return self;
}

- (void)loginWithSuccessBlock:(LoginSuccessBlock)successBlock {
    if (self.twitterAPI) {
        if (successBlock) successBlock(self.username);
        return;
    }
    
    ACAccountStore *store = [[ACAccountStore alloc] init];
    ACAccountType *twitterType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [store requestAccessToAccountsWithType:twitterType options:nil completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                self.accounts = [store accountsWithAccountType:twitterType];
                
                if ([self.accounts count] == 0) {
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not find any available Twitter accounts." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                } else {
                    self.successBlock = successBlock;
                    
                    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Twitter Account:" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
                    for (ACAccount *account in self.accounts)
                        [actionSheet addButtonWithTitle:account.username];
                    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
                    [actionSheet showInView:[[[UIApplication sharedApplication] delegate] window]];
                }
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not access Twitter accounts." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        });
        
    }];
}

- (void)logout {
    self.twitterAPI = nil;
    self.username = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"twitter_account"];
    [defaults synchronize];
}

- (void)follow:(NSString *)username successBlock:(void (^)(int isProtected))successBlock {
    if (!self.twitterAPI) {
        [self loginWithSuccessBlock:^(NSString *user) {
            [self follow:username successBlock:successBlock];
        }];
        return;
    }
    
    [self.twitterAPI postFollow:username successBlock:^(NSDictionary *user) {
        if (successBlock) successBlock([user[@"protected"] intValue]);
    } errorBlock:^(NSError *error) {
        if (error.code == 160) { // already requested
            if (successBlock) successBlock(YES);
        } else
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not follow user." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (void)unfollow:(NSString *)username successBlock:(void (^)())successBlock {
    if (!self.twitterAPI) {
        [self loginWithSuccessBlock:^(NSString *user) {
            [self unfollow:username successBlock:successBlock];
        }];
        return;
    }
    
    [self.twitterAPI postUnfollow:username successBlock:^(NSDictionary *user) {
        if (successBlock) successBlock();
    } errorBlock:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not unfollow user." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (void)check:(NSString *)username successBlock:(void (^)(TwitterStatus))successBlock {
    if (!self.twitterAPI) return;
    
    [self.twitterAPI getFriendshipShowForSourceID:nil orSourceScreenName:self.username targetID:nil orTargetScreenName:username successBlock:^(id relationship) {
        if ([relationship[@"relationship"][@"source"][@"following"] boolValue]) {
            if (successBlock) successBlock(TwitterStatusFollowing);
        } else if ([relationship[@"relationship"][@"source"][@"following_requested"] boolValue]) {
            if (successBlock) successBlock(TwitterStatusRequested);
        } else {
            if (successBlock) successBlock(TwitterStatusNotFollowing);
        }
    } errorBlock:^(NSError *error) {
        // do nothing
    }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (!self.accounts || buttonIndex >= [self.accounts count]) return;
    
    ACAccount *account = self.accounts[buttonIndex];
    
    self.twitterAPI = [STTwitterAPI twitterAPIOSWithAccount:account];
    self.username = account.username;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:account.identifier forKey:@"twitter_account"];
    [defaults synchronize];
    
    if (self.successBlock) self.successBlock(self.username);
}

@end
