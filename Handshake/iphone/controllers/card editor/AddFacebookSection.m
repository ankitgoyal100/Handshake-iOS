//
//  NewFacebookSection.m
//  Handshake
//
//  Created by Sam Ober on 9/12/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "AddFacebookSection.h"
#import "AddFacebookTableViewCell.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FacebookHelper.h"
#import "Social.h"
#import <CoreData/CoreData.h>

@interface AddFacebookSection()

@property (nonatomic, strong) Card *card;

@property (nonatomic, strong) AddFacebookTableViewCell *addFacebookCell;

@property (nonatomic, copy) AddFacebookSuccess successBlock;

@end

@implementation AddFacebookSection

- (AddFacebookTableViewCell *)addFacebookCell {
    if (!_addFacebookCell) {
        _addFacebookCell = [[AddFacebookTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    return _addFacebookCell;
}

- (id)initWithCard:(Card *)card successBlock:(AddFacebookSuccess)successBlock viewController:(SectionBasedTableViewController *)viewController {
    self = [super initWithViewController:viewController];
    if (self) {
        self.card = card;
        self.successBlock = successBlock;
        
        [self loadFacebook];
    }
    return self;
}

- (int)rows {
    return 1;
}

- (BaseTableViewCell *)cellForRow:(int)row indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    return self.addFacebookCell;
}

- (void)cellWasSelectedAtRow:(int)row indexPath:(NSIndexPath *)indexPath {
    if (FBSession.activeSession.state != FBSessionStateOpen) {
        [[FacebookHelper sharedHelper] loginWithSuccessBlock:^(NSString *username, NSString *name) {
            self.addFacebookCell.loading = NO;
            self.addFacebookCell.name = name;
        } errorBlock:^(NSError *error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not add Facebook account. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    } else if (!self.addFacebookCell.loading) {
        Social *social = [[Social alloc] initWithEntity:[NSEntityDescription entityForName:@"Social" inManagedObjectContext:self.card.managedObjectContext] insertIntoManagedObjectContext:self.card.managedObjectContext];
        social.username = [[FacebookHelper sharedHelper] username];
        social.network = @"facebook";
        [self.card addSocialsObject:social];
        if (self.successBlock) self.successBlock();
    }
}

- (void)loadFacebook {
    if (FBSession.activeSession.state == FBSessionStateOpen) {
        self.addFacebookCell.loading = YES;
        [[FacebookHelper sharedHelper] loadFacebookAccountWithSuccessBlock:^(NSString *username, NSString *name) {
            self.addFacebookCell.loading = NO;
            self.addFacebookCell.name = name;
        } errorBlock:^(NSError *error) {
            [self loadFacebook];
        }];
    }
}

@end
