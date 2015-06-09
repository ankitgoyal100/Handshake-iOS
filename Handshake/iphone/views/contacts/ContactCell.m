//
//  ContactCell.m
//  Handshake
//
//  Created by Sam Ober on 4/24/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "ContactCell.h"
#import "User.h"
#import "UIControl+Blocks.h"
#import "FeedItem.h"

@interface ContactCell() <UIActionSheetDelegate>

@end

@implementation ContactCell

- (void)setContact:(Contact *)contact {
    _contact = contact;
    
    self.pictureView.imageURL = nil;
    self.pictureView.image = nil;
    if ([self.contact.user cachedImage])
        self.pictureView.image = [self.contact.user cachedImage];
    else if (self.contact.user.picture)
        self.pictureView.imageURL = [NSURL URLWithString:self.contact.user.picture];
    else
        self.pictureView.image = [UIImage imageNamed:@"default_picture"];
    
    self.nameLabel.text = [self.contact.user formattedName];
    
    if ([self.contact.user.mutual intValue] == 1)
        self.detailLabel.text = @"1 mutual contact";
    else
        self.detailLabel.text = [NSString stringWithFormat:@"%d mutual contacts", [self.contact.user.mutual intValue]];
    
    [self.contactsButton addEventHandler:^(id sender) {
        [[[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Are you sure? You and %@ will no longer be contacts.", [self.contact.user formattedName]] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Contact" otherButtonTitles:nil] showInView:self];
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete Contact"]) {
        self.contact.syncStatus = @(ContactDeleted);
        for (FeedItem *item in self.contact.feedItems)
            [self.contact.managedObjectContext deleteObject:item];
        if (self.deleteBlock) self.deleteBlock();
    }
}

@end
