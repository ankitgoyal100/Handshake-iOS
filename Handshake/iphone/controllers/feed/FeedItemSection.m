//
//  FeedItemSection.m
//  Handshake
//
//  Created by Sam Ober on 6/16/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "FeedItemSection.h"
#import "FeedItem.h"
#import "FeedItemCell.h"
#import "User.h"
#import "Group.h"
#import "HandshakeSession.h"
#import "Account.h"
#import "UserViewController.h"
#import "GroupViewController.h"

@implementation FeedItemSection

- (NSInteger)numberOfRows {
    return 1 + [self.feedItems count];
}

- (UITableViewCell *)cellAtIndex:(NSInteger)index inTableView:(UITableView *)tableView {
    if (index == 0) return [tableView dequeueReusableCellWithIdentifier:@"Separator"];
    
    FeedItem *item = self.feedItems[index - 1];
    
    FeedItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedItemCell"];
    
    if ([item.itemType isEqualToString:@"new_contact"] || [item.itemType isEqualToString:@"card_updated"] || [item.itemType isEqualToString:@"new_group_member"])
        if (!item.user) return cell;
    if ([item.itemType isEqualToString:@"group_joined"] || [item.itemType isEqualToString:@"new_group_member"])
        if (!item.group) return cell;
    
    cell.pictureView.image = nil;
    if (item.user) {
        if ([item.user cachedThumb])
            cell.pictureView.image = [item.user cachedThumb];
        else if (item.user.thumb)
            cell.pictureView.imageURL = [NSURL URLWithString:item.user.thumb];
        else
            cell.pictureView.image = [UIImage imageNamed:@"default_picture"];
    } else {
        Account *account = [[HandshakeSession currentSession] account];
        if ([account cachedThumb])
            cell.pictureView.image = [account cachedThumb];
        else if (account.thumb)
            cell.pictureView.imageURL = [NSURL URLWithString:account.thumb];
        else
            cell.pictureView.image = [UIImage imageNamed:@"default_picture"];
    }
    
    cell.messageLabel.attributedText = [self messageForItem:item];
    
    NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:item.createdAt];
    
    if (time < 60) {
        if ((int)time == 1)
            cell.dateLabel.text = @"1 second ago";
        else
            cell.dateLabel.text = [NSString stringWithFormat:@"%d seconds ago", (int)time];
    } else {
        time /= 60;
        
        if (time < 60) {
            if ((int)time == 1)
                cell.dateLabel.text = @"1 minute ago";
            else
                cell.dateLabel.text = [NSString stringWithFormat:@"%d minutes ago", (int)time];
        } else {
            time /= 60;
            
            if (time < 24) {
                if ((int)time == 1)
                    cell.dateLabel.text = @"1 hour ago";
                else
                    cell.dateLabel.text = [NSString stringWithFormat:@"%d hours ago", (int)time];
            } else {
                time /= 24;
                
                if (time < 7) {
                    if ((int)time == 1)
                        cell.dateLabel.text = @"1 day ago";
                    else
                        cell.dateLabel.text = [NSString stringWithFormat:@"%d days ago", (int)time];
                } else {
                    time /= 7;
                    
                    if (time < 4.34812) {
                        if ((int)time == 1)
                            cell.dateLabel.text = @"1 week ago";
                        else
                            cell.dateLabel.text = [NSString stringWithFormat:@"%d weeks ago", (int)time];
                    } else {
                        time /= 4.34812;
                        
                        if (time < 12) {
                            if ((int)time == 1)
                                cell.dateLabel.text = @"1 month ago";
                            else
                                cell.dateLabel.text = [NSString stringWithFormat:@"%d months ago", (int)time];
                        } else {
                            time /= 12;
                            
                            if ((int)time == 1)
                                cell.dateLabel.text = @"1 year ago";
                            else
                                cell.dateLabel.text = [NSString stringWithFormat:@"%d years ago", (int)time];
                        }
                    }
                }
            }
        }
    }
    
    return cell;
}

- (NSAttributedString *)messageForItem:(FeedItem *)item {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setMinimumLineHeight:18];
    
    NSDictionary *attrs = @{ NSFontAttributeName: [UIFont systemFontOfSize:14], NSParagraphStyleAttributeName: paragraphStyle };
    NSDictionary *boldAttrs = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:14], NSParagraphStyleAttributeName: paragraphStyle };
    
    if ([item.itemType isEqualToString:@"new_contact"]) {
        NSMutableAttributedString *messageString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ added you!", [item.user formattedName]] attributes:attrs];
        
        [messageString setAttributes:boldAttrs range:[messageString.string rangeOfString:[item.user formattedName]]];
        
        return messageString;
    } else if ([item.itemType isEqualToString:@"card_updated"]) {
        NSMutableAttributedString *messageString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ got new contact information.", [item.user formattedName]] attributes:attrs];
        
        [messageString setAttributes:boldAttrs range:[messageString.string rangeOfString:[item.user formattedName]]];
        
        return messageString;
    } else if ([item.itemType isEqualToString:@"group_joined"]) {
        NSMutableAttributedString *messageString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"You joined %@.", item.group.name] attributes:attrs];
        
        [messageString setAttributes:boldAttrs range:[messageString.string rangeOfString:item.group.name]];
        
        return messageString;
    } else if ([item.itemType isEqualToString:@"new_group_member"]) {
        NSMutableAttributedString *messageString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ joined %@.", [item.user formattedName], item.group.name] attributes:attrs];
        
        [messageString setAttributes:boldAttrs range:[messageString.string rangeOfString:[item.user formattedName]]];
        [messageString setAttributes:boldAttrs range:[messageString.string rangeOfString:item.group.name]];
        
        return messageString;
    }
    
    return nil;
}

- (CGFloat)heightForCellAtIndex:(NSInteger)index {
    if (index == 0) return 1;
    
    FeedItem *item = self.feedItems[index - 1];
    
    if ([item.itemType isEqualToString:@"new_contact"] || [item.itemType isEqualToString:@"card_updated"] || [item.itemType isEqualToString:@"new_group_member"])
        if (!item.user) return 0;
    if ([item.itemType isEqualToString:@"group_joined"] || [item.itemType isEqualToString:@"new_group_member"])
        if (!item.group) return 0;
    
    NSAttributedString *messageString = [self messageForItem:item];
    
    //NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    //[paragrahStyle setMinimumLineHeight:20];
    
    //NSDictionary *attributesDictionary = @{ NSFontAttributeName: [UIFont systemFontOfSize:15], NSParagraphStyleAttributeName: paragrahStyle };
    CGRect frame = [messageString boundingRectWithSize:CGSizeMake(self.viewController.view.frame.size.width - 80, 10000) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
    return MAX(67, 17 + 19 + frame.size.height + 1);
}

- (void)cellWasSelectedAtIndex:(NSInteger)index {
    if (index == 0) return;
    
    FeedItem *item = self.feedItems[index - 1];
    
    if (item.user) {
        UserViewController *controller = [self.viewController.storyboard instantiateViewControllerWithIdentifier:@"UserViewController"];
        controller.user = item.user;
        [self.viewController.navigationController pushViewController:controller animated:YES];
    } else if (item.group) {
        GroupViewController *controller = [self.viewController.storyboard instantiateViewControllerWithIdentifier:@"GroupViewController"];
        controller.group = item.group;
        [self.viewController.navigationController pushViewController:controller animated:YES];
    }
}

@end
