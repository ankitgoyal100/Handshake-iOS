//
//  SocialAccountsSection.m
//  Handshake
//
//  Created by Sam Ober on 9/22/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "SocialAccountsSection.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SocialAccountTableViewCell.h"
#import "FacebookHelper.h"
#import "TwitterHelper.h"

@interface SocialAccountsSection() <UIActionSheetDelegate>

@property (nonatomic, strong) SocialAccountTableViewCell *facebookCell;
@property (nonatomic, strong) SocialAccountTableViewCell *twitterCell;

@end

@implementation SocialAccountsSection

- (SocialAccountTableViewCell *)facebookCell {
    if (!_facebookCell) {
        _facebookCell = [[SocialAccountTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        _facebookCell.iconView.image = [UIImage imageNamed:@"facebook.png"];
        _facebookCell.placeholder = @"CONNECT TO FACEBOOK";
    }
    return _facebookCell;
}

- (SocialAccountTableViewCell *)twitterCell {
    if (!_twitterCell) {
        _twitterCell = [[SocialAccountTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        _twitterCell.iconView.image = [UIImage imageNamed:@"twitter.png"];
        _twitterCell.placeholder = @"CONNECT TO TWITTER";
    }
    return _twitterCell;
}

- (int)rows {
    return 2;
}

- (id)initWithViewController:(SectionBasedTableViewController *)controller {
    self = [super initWithViewController:controller];
    if (self) {
        
    }
    return self;
}

- (BaseTableViewCell *)cellForRow:(int)row indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    if (row == 0) {
        if (FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
            [[FacebookHelper sharedHelper] loginWithSuccessBlock:^(NSString *username, NSString *name) {
                self.facebookCell.username = name;
            } errorBlock:^(NSError *error) {
                
            }];
        }
        
        return self.facebookCell;
    }
    
    if (row == 1) {
        if ([[TwitterHelper sharedHelper] username]) {
            self.twitterCell.username = [@"@" stringByAppendingString:[[TwitterHelper sharedHelper] username]];
        }
        
        return self.twitterCell;
    }
    
    return nil;
}

- (void)cellWasSelectedAtRow:(int)row indexPath:(NSIndexPath *)indexPath {
    if (row == 0) {
        if (FBSession.activeSession.state == FBSessionStateOpen) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Logged in as %@", [[FacebookHelper sharedHelper] name]] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Logout" otherButtonTitles:nil];
            actionSheet.tag = 1;
            [actionSheet showInView:self.viewController.view];
        } else {
            [[FacebookHelper sharedHelper] loginWithSuccessBlock:^(NSString *username, NSString *name) {
                self.facebookCell.username = name;
            } errorBlock:^(NSError *error) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not login to Facebook." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }];
        }
    } else if (row == 1) {
        if ([[TwitterHelper sharedHelper] username]) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Logged in as @%@", [[TwitterHelper sharedHelper] username]] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Logout" otherButtonTitles:nil];
            actionSheet.tag = 2;
            [actionSheet showInView:self.viewController.view];
        } else {
            [[TwitterHelper sharedHelper] loginWithSuccessBlock:^(NSString *username) {
                self.twitterCell.username = [@"@" stringByAppendingString:username];
            }];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Logout"]) {
        if (actionSheet.tag == 1) {
            [[FacebookHelper sharedHelper] logout];
            self.facebookCell.placeholder = self.facebookCell.placeholder;
        } else if (actionSheet.tag == 2) {
            [[TwitterHelper sharedHelper] logout];
            self.twitterCell.placeholder = self.twitterCell.placeholder;
        }
    }
}

@end
