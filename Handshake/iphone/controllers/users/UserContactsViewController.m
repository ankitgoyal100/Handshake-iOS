//
//  UserContactsViewController.m
//  Handshake
//
//  Created by Sam Ober on 6/8/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "UserContactsViewController.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"
#import "HandshakeCoreDataStore.h"
#import "HandshakeSession.h"
#import "HandshakeClient.h"
#import "ContactCell.h"
#import "UserRequestCell.h"
#import "SearchResultCell.h"
#import "UIControl+Blocks.h"
#import "UserViewController.h"
#import "UserServerSync.h"

@interface UserContactsViewController ()

@property (nonatomic, strong) NSArray *contacts;

@property (nonatomic) BOOL loaded;

@end

@implementation UserContactsViewController

- (NSArray *)contacts {
    if (!_contacts) _contacts = [[NSArray alloc] init];
    return _contacts;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loaded = NO;
    
    self.title = @"Contacts";
    
    if (self.navigationController && [self.navigationController.viewControllers indexOfObject:self] != 0)
        [self.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
    
    if (self.user)
        [self load];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)load {
    self.loaded = NO;
    
    [[HandshakeClient client] GET:[NSString stringWithFormat:@"/users/%@/contacts", self.user.userId] parameters:[[HandshakeSession currentSession] credentials] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (![self.navigationController.viewControllers containsObject:self]) return;
        
        [UserServerSync cacheUsers:responseObject[@"contacts"] completionBlock:^(NSArray *users) {
            self.contacts = [users sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]]];
            self.loaded = YES;
            [self.tableView reloadData];
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([[operation response] statusCode] == 401)
            [[HandshakeSession currentSession] invalidate];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.contacts count] == 0) return 1;
    
    return [self.contacts count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.loaded) return [tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
    
    if ([self.contacts count] == 0) return [tableView dequeueReusableCellWithIdentifier:@"NoResultsCell"];
    
    if (indexPath.row == 0) return [tableView dequeueReusableCellWithIdentifier:@"Separator"];
    
    User *user = self.contacts[indexPath.row - 1];
    
    if ([user.isContact boolValue]) {
        ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
        cell.user = user;
        [cell setDeleteBlock:^(void) {
            [self.tableView reloadData];
        }];
        return cell;
    }
    
    if ([user.requestReceived boolValue]) {
        UserRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserRequestCell"];
        cell.user = user;
        return cell;
    }
    
    SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultCell"];
    cell.user = user;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.loaded && [self.contacts count] > 0 && indexPath.row == 0) return 1;
    
    return 57;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) return;
    
    User *user = self.contacts[indexPath.row - 1];
    
    UserViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"UserViewController"];
    controller.user = user;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
