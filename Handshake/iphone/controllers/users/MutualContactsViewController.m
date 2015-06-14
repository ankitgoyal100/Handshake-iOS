//
//  MutualContactsViewController.m
//  Handshake
//
//  Created by Sam Ober on 6/8/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "MutualContactsViewController.h"
#import "HandshakeCoreDataStore.h"
#import "HandshakeSession.h"
#import "HandshakeClient.h"
#import "ContactCell.h"
#import "UserViewController.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"
#import "User.h"
#import "UserServerSync.h"

@interface MutualContactsViewController ()

@property (nonatomic, strong) NSMutableArray *contacts;

@property (nonatomic) BOOL loaded;

@end

@implementation MutualContactsViewController

- (NSMutableArray *)contacts {
    if (!_contacts) _contacts = [[NSMutableArray alloc] init];
    return _contacts;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Mutual Contacts";
    
    if (self.navigationController && [self.navigationController.viewControllers indexOfObject:self] != 0)
        [self.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
    
    self.loaded = NO;
    
    if (self.user)
        [self load];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // check contacts
    for (User *contact in self.contacts)
        if (!contact.managedObjectContext || [contact.syncStatus intValue] == UserDeleted)
            [self.contacts removeObject:contact];
    
    [self.tableView reloadData];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)load {
    [[HandshakeClient client] GET:[NSString stringWithFormat:@"/users/%@/mutual", self.user.userId] parameters:[[HandshakeSession currentSession] credentials] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (![self.navigationController.viewControllers containsObject:self]) return;
        
        [UserServerSync cacheUsers:responseObject[@"mutual"] completionBlock:^(NSArray *users) {
            self.contacts = [[users sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]]] mutableCopy];
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
    
    __weak ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    cell.user = self.contacts[indexPath.row - 1];
    [cell setDeleteBlock:^(void) {
        [self.contacts removeObject:cell.user];
        [self.tableView reloadData];
    }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.loaded && [self.contacts count] > 0 && indexPath.row == 0) return 1;
    
    return 57;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) return;
    
    User *contact = self.contacts[indexPath.row - 1];

    UserViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"UserViewController"];
    controller.user = contact;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
