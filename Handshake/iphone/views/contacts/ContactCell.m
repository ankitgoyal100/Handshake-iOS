//
//  ContactCell.m
//  Handshake
//
//  Created by Sam Ober on 4/24/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "ContactCell.h"
#import "UIControl+Blocks.h"
#import "FeedItem.h"
#import "ContactServerSync.h"

@interface ContactCell() <UIActionSheetDelegate>

@end

@implementation ContactCell

- (void)setUser:(User *)user {
    _user = user;
    
    self.pictureView.imageURL = nil;
    self.pictureView.image = nil;
    if ([user cachedThumb])
        self.pictureView.image = [user cachedThumb];
    else if (user.thumb)
        self.pictureView.imageURL = [NSURL URLWithString:user.thumb];
    else
        self.pictureView.image = [UIImage imageNamed:@"default_picture"];
    
    self.nameLabel.text = [user formattedName];
    
    if ([user.mutual intValue] == 1)
        self.detailLabel.text = @"1 mutual contact";
    else
        self.detailLabel.text = [NSString stringWithFormat:@"%d mutual contacts", [user.mutual intValue]];
    
    [self.contactsButton addEventHandler:^(id sender) {
        [[[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Are you sure? You and %@ will no longer be contacts.", [user formattedName]] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Contact" otherButtonTitles:nil] showInView:self];
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete Contact"]) {
        [ContactServerSync deleteContact:self.user];
        if (self.deleteBlock) self.deleteBlock();
    }
}

@end
