//
//  EmailSettingsSection.m
//  Handshake
//
//  Created by Sam Ober on 9/10/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "EmailSettingsSection.h"
#import "EmailSettingsTableViewCell.h"
#import "HandshakeSession.h"
#import "Handshake.h"
#import "ResendConfirmationTableViewCell.h"
#import "NewEmailViewController.h"
#import "HandshakeClient.h"
#import "HandshakeCoreDataStore.h"

@interface EmailSettingsSection()

@property (nonatomic, strong) EmailSettingsTableViewCell *emailCell;

@end

@implementation EmailSettingsSection

- (EmailSettingsTableViewCell *)emailCell {
    if (!_emailCell) {
        _emailCell = [[EmailSettingsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    return _emailCell;
}

- (id)initWithViewController:(SectionBasedTableViewController *)controller {
    self = [super initWithViewController:controller];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedIn) name:LOGGED_IN_NOTIFICATION object:nil];
    }
    return self;
}

- (int)rows {
    return 1;
}

- (BaseTableViewCell *)cellForRow:(int)row indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    Account *account = [[HandshakeSession currentSession] account];
    
    self.emailCell.emailLabel.text = account.email;
    [self.emailCell.editButton addTarget:self action:@selector(newEmail) forControlEvents:UIControlEventTouchUpInside];
    return self.emailCell;
}

- (void)cellWasSelectedAtRow:(int)row indexPath:(NSIndexPath *)indexPath {
    
}

- (void)newEmail {
    [self newEmail:nil];
}

- (void)newEmail:(NSString *)email {
    NewEmailViewController *controller = [[NewEmailViewController alloc] initWithEmail:email successBlock:^(NSString *newEmail) {
        self.emailCell.emailLabel.text = newEmail;
        
        int rows = [self rows];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[HandshakeSession currentSession] credentials]];
        params[@"email"] = newEmail;
        
        [[HandshakeClient client] PUT:@"/account" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            // update the user
            [[[HandshakeSession currentSession] account] updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:responseObject[@"user"]]];
            [[[HandshakeSession currentSession] account].managedObjectContext save:nil];
            
            // if were missing a row animate it in
            if ([self rows] == 2 && rows == 1)
                [self insertRowAtRow:1];
            
            // if we have too many rows animate one out
            if ([self rows] == 1 && rows == 2)
                [self removeRowAtRow:1];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([[operation response] statusCode] == 401) {
                [[HandshakeSession currentSession] invalidate];
            } else {
                [self newEmail:newEmail];
                if ([[operation response] statusCode] == 422) {
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:nil][@"errors"][0] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                } else
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not update email. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            }
        }];
    }];
    [self.viewController.navigationController pushViewController:controller animated:YES];
}

- (void)loggedIn {
    [self.viewController.tableView reloadData];
}

@end
