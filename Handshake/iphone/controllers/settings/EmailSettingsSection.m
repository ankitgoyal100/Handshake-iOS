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
@property (nonatomic, strong) ResendConfirmationTableViewCell *resendCell;

@end

@implementation EmailSettingsSection

- (EmailSettingsTableViewCell *)emailCell {
    if (!_emailCell) {
        _emailCell = [[EmailSettingsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    return _emailCell;
}

- (ResendConfirmationTableViewCell *)resendCell {
    if (!_resendCell) {
        _resendCell = [[ResendConfirmationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    return _resendCell;
}

- (id)initWithViewController:(SectionBasedTableViewController *)controller {
    self = [super initWithViewController:controller];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedIn) name:LOGGED_IN_NOTIFICATION object:nil];
    }
    return self;
}

- (int)rows {
    User *user = [HandshakeSession user];
    
    // check if email is confirmed
    if (user.confirmedAt && !user.unconfirmedEmail)
        return 1;
    return 2;
}

- (BaseTableViewCell *)cellForRow:(int)row indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    User *user = [HandshakeSession user];
    
    if (row == 0) {
        if (user.unconfirmedEmail)
            self.emailCell.emailLabel.text = user.unconfirmedEmail;
        else
            self.emailCell.emailLabel.text = user.email;
        [self.emailCell.editButton addTarget:self action:@selector(newEmail) forControlEvents:UIControlEventTouchUpInside];
        return self.emailCell;
    }
    
    NSTimeInterval timeLeft = 172800 - (([[NSDate date] timeIntervalSince1970] - [user.confirmationSentAt timeIntervalSince1970]) / 1000.0);
    if (timeLeft < 60) {
        self.resendCell.timeLeftLabel.text = [[[NSNumber numberWithInt:timeLeft] stringValue] stringByAppendingString:@" SECONDS LEFT"];
    } else if (timeLeft < 3600) {
        self.resendCell.timeLeftLabel.text = [[[NSNumber numberWithInt:timeLeft / 60] stringValue] stringByAppendingString:@" MINUTES LEFT"];
    } else if (timeLeft < 86400) {
        self.resendCell.timeLeftLabel.text = [[[NSNumber numberWithInt:timeLeft / 3600] stringValue] stringByAppendingString:@" HOURS LEFT"];
    } else if (timeLeft < 2630000) {
        self.resendCell.timeLeftLabel.text = [[[NSNumber numberWithInt:timeLeft / 86400] stringValue] stringByAppendingString:@" DAYS LEFT"];
    }
    
    return self.resendCell;
}

- (void)cellWasSelectedAtRow:(int)row indexPath:(NSIndexPath *)indexPath {
    if (row == 1) {
        self.resendCell.loading = YES;
        User *user = [HandshakeSession user];
        [[HandshakeClient client] POST:@"/confirmation" parameters:@{ @"user":@{ @"email":user.email } } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.resendCell.loading = NO;
            [[[UIAlertView alloc] initWithTitle:@"Confirmation Resent" message:@"You should receive an email shortly." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            self.resendCell.loading = NO;
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not resend confirmation email. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    }
}

- (void)newEmail {
    [self newEmail:nil];
}

- (void)newEmail:(NSString *)email {
    NewEmailViewController *controller = [[NewEmailViewController alloc] initWithEmail:email successBlock:^(NSString *newEmail) {
        self.emailCell.emailLabel.text = newEmail;
        
        int rows = [self rows];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[HandshakeSession credentials]];
        params[@"email"] = newEmail;
        
        [[HandshakeClient client] PUT:@"/account" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            // update the user
            [[HandshakeSession user] updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:responseObject[@"user"]]];
            [[HandshakeSession user].managedObjectContext save:nil];
            
            // if were missing a row animate it in
            if ([self rows] == 2 && rows == 1)
                [self insertRowAtRow:1];
            
            // if we have too many rows animate one out
            if ([self rows] == 1 && rows == 2)
                [self removeRowAtRow:1];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([[operation response] statusCode] == 401) {
                [HandshakeSession invalidate];
            } else {
                [self newEmail:newEmail];
                if ([[operation response] statusCode] == 422) {
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:nil][0] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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
