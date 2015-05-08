//
//  LogoutSection.m
//  Handshake
//
//  Created by Sam Ober on 9/10/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "LogoutSection.h"
#import "LogoutTableViewCell.h"
#import "HandshakeSession.h"
#import "Handshake.h"
#import "StartViewController.h"
#import "Contact.h"
#import "Card.h"
#import "HandshakeCoreDataStore.h"
#import "AsyncImageView.h"

@interface LogoutSection() <UIAlertViewDelegate>

@property (nonatomic, strong) LogoutTableViewCell *logoutCell;

@property (nonatomic, strong) StartViewController *startController;

@end

@implementation LogoutSection

- (LogoutTableViewCell *)logoutCell {
    if (!_logoutCell) {
        _logoutCell = [[LogoutTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    return _logoutCell;
}

- (int)rows {
    return 1;
}

- (BaseTableViewCell *)cellForRow:(int)row indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    return self.logoutCell;
}

- (void)cellWasSelectedAtRow:(int)row indexPath:(NSIndexPath *)indexPath {
    [[[UIAlertView alloc] initWithTitle:@"Logout" message:@"Are you sure you want to logout?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Logout", nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Logout"]) {
        self.startController = [[StartViewController alloc] initWithLoading:YES];
        UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:self.startController];
        controller.navigationBarHidden = YES;
        //controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self.viewController.view.window setRootViewController:controller];
        //[self.viewController presentViewController:controller animated:YES completion:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(synced) name:CardSyncCompleted object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(synced) name:ContactSyncCompleted object:nil];
        
        // sync
        [Card sync];
        [Contact sync];
    }
}

- (void)synced {
    if (![Contact syncing] && ![Card syncing] && self.startController) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        // remove all data
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Card"];
        
        __block NSArray *results;
        
        __block NSManagedObjectContext *objectContext = [[HandshakeCoreDataStore defaultStore] childObjectContext];
        
        [objectContext performBlockAndWait:^{
            NSError *error;
            results = [objectContext executeFetchRequest:request error:&error];
        }];
        
        if (results) {
            for (Card *card in results) {
                [objectContext deleteObject:card];
            }
        }
        
        request = [[NSFetchRequest alloc] initWithEntityName:@"Contact"];
        
        [objectContext performBlockAndWait:^{
            NSError *error;
            results = [objectContext executeFetchRequest:request error:&error];
        }];
        
        if (results) {
            for (Contact *contact in results) {
                [objectContext deleteObject:contact];
            }
        }
        
        // save
        [objectContext performBlockAndWait:^{
            [objectContext save:nil];
        }];
        
        // clear AsyncImageView cache
        [[AsyncImageLoader defaultCache] removeAllObjects];
        
        [[HandshakeSession currentSession] logout];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.startController.loading = NO;
        });
    }
}

@end
