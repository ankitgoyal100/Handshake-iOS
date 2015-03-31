//
//  ContactSocialSection.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "ContactSocialSection.h"
#import "FacebookTableViewCell.h"
#import "TwitterTableViewCell.h"
#import "FacebookHelper.h"
#import "Social.h"
#import "UIControl+Blocks.h"
#import "TwitterHelper.h"

@interface ContactSocialSection()

@property (nonatomic, strong) Card *card;

@end

@implementation ContactSocialSection

- (id)initWithCard:(Card *)card viewController:(SectionBasedTableViewController *)viewController {
    self = [super initWithViewController:viewController];
    if (self) {
        self.card = card;
    }
    return self;
}

- (int)rows{
    return (int)[self.card.socials count];
}

- (BaseTableViewCell *)cellForRow:(int)row indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    Social *social = self.card.socials[row];
    
    if ([social.network isEqualToString:@"facebook"]) {
        FacebookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FacebookCell"];
        
        if (!cell) cell = [[FacebookTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FacebookCell"];
        
        cell.showsFriendButton = NO;
        
        [[FacebookHelper sharedHelper] nameForUsername:social.username successBlock:^(NSString *name) {
            cell.nameLabel.text = name;
        } errorBlock:^(NSError *error) {
            cell.nameLabel.text = social.username;
        }];
        
        return cell;
    }
    
    if ([social.network isEqualToString:@"twitter"]) {
        TwitterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwitterCell"];
        
        if (!cell) cell = [[TwitterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TwitterCell"];
        
        cell.username = social.username;
        
        __weak typeof(cell) weakCell = cell;
        
        [[TwitterHelper sharedHelper] check:social.username successBlock:^(TwitterStatus status) {
            weakCell.status = status;
        }];
        
        [cell.followButton addEventHandler:^(id sender) {
            if (indexPath.row != [tableView indexPathForCell:weakCell].row || weakCell.loading) return;
            
            weakCell.loading = YES;
            
            if (weakCell.status == TwitterStatusNotFollowing) {
                [[TwitterHelper sharedHelper] follow:social.username successBlock:^(int isProtected) {
                    if (isProtected == 1)
                        weakCell.status = TwitterStatusRequested;
                    else
                        weakCell.status = TwitterStatusFollowing;
                    
                    weakCell.loading = NO;
                }];
            } else if (weakCell.status == TwitterStatusFollowing || weakCell.status == TwitterStatusRequested) {
                [[TwitterHelper sharedHelper] unfollow:social.username successBlock:^{
                    weakCell.status = TwitterStatusNotFollowing;
                    weakCell.loading = NO;
                }];
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    
    return nil;
}

- (void)cellWasSelectedAtRow:(int)row indexPath:(NSIndexPath *)indexPath {
    Social *social = self.card.socials[row];
    
    if ([social.network isEqualToString:@"facebook"]) {
        NSURL *facebookURL = [NSURL URLWithString:[@"fb://profile/" stringByAppendingString:social.username]];
        if ([[UIApplication sharedApplication] canOpenURL:facebookURL])
            [[UIApplication sharedApplication] openURL:facebookURL];
        else
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"http://facebook.com/" stringByAppendingString:social.username]]];
    }
    
    if ([social.network isEqualToString:@"twitter"]) {
        NSURL *twitterURL = [NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:social.username]];
        if ([[UIApplication sharedApplication] canOpenURL:twitterURL])
            [[UIApplication sharedApplication] openURL:twitterURL];
        else
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"http://twitter.com/" stringByAppendingString:social.username]]];
    }
}

@end
