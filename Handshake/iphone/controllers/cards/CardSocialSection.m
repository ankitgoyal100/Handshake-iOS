//
//  CardSocialSection.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "CardSocialSection.h"
#import "FacebookTableViewCell.h"
#import "TwitterTableViewCell.h"
#import "FacebookHelper.h"
#import "Social.h"

@interface CardSocialSection()

@property (nonatomic, strong) Card *card;

@end

@implementation CardSocialSection

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
        
        [FacebookHelper nameForUsername:social.username successBlock:^(NSString *name) {
            cell.nameLabel.text = name;
        } errorBlock:^(NSError *error) {
            cell.nameLabel.text = social.username;
        }];
        
        //cell.nameLabel.text = social.username;
        cell.showsFriendButton = NO;
        
        return cell;
    }
    
    if ([social.network isEqualToString:@"twitter"]) {
        TwitterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwitterCell"];
        
        if (!cell) cell = [[TwitterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TwitterCell"];
        
        cell.username = social.username;
        cell.showsFollowButton = NO;
        
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
