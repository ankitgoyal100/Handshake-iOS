//
//  SettingsViewController.m
//  Handshake
//
//  Created by Sam Ober on 9/10/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "SettingsViewController.h"
#import "HandshakeCoreDataStore.h"
#import "HandshakeSession.h"
#import "HandshakeCoreDataStore.h"
#import "HandshakeClient.h"
#import "FacebookHelper.h"

@interface SettingsViewController() <UIAlertViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel *emailField;
@property (weak, nonatomic) IBOutlet UILabel *facebookLabel;
@property (weak, nonatomic) IBOutlet UILabel *autoSyncLabel;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Settings";
    
    if ([FacebookHelper sharedHelper].username)
        self.facebookLabel.text = [FacebookHelper sharedHelper].name;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.emailField.text = [[HandshakeSession currentSession] account].email;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"auto_sync"][@"enabled"] boolValue])
        self.autoSyncLabel.text = @"On";
    else
        self.autoSyncLabel.text = @"Off";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 1) {
        // email
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"ChangeEmailViewController"] animated:YES];
    }
    
    if (indexPath.row == 4) {
        // autosync
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"ContactSyncSettingsViewController"] animated:YES];
    }
    
    if (indexPath.row == 7) {
        // facebook
        if ([FacebookHelper sharedHelper].username) {
            [[[UIActionSheet alloc] initWithTitle:@"Facebook Account" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Disconnect" otherButtonTitles:nil] showInView:self.view];
        } else {
            [[FacebookHelper sharedHelper] loginWithSuccessBlock:^(NSString *username, NSString *name) {
                self.facebookLabel.text = name;
            } errorBlock:^(NSError *error) {
                [[[UIAlertView alloc] initWithTitle:@"" message:@"Couldn't connect to Facebook" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }];
        }
    }
}

- (IBAction)logout:(id)sender {
    [[[UIAlertView alloc] initWithTitle:nil message:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Log Out", nil] show];
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Log Out"]) {
        [[HandshakeSession currentSession] logout];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Disconnect"]) {
        [[FacebookHelper sharedHelper] logout];
        self.facebookLabel.text = @"Not Connected";
    }
}


@end
