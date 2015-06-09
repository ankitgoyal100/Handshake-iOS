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
#import "Contact.h"
#import "UserViewController.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"

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
    for (Contact *contact in self.contacts)
        if (!contact.managedObjectContext || [contact.syncStatus intValue] == ContactDeleted)
            [self.contacts removeObject:contact];
    
    [self.tableView reloadData];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)load {
    [[HandshakeClient client] GET:[NSString stringWithFormat:@"/users/%@/mutual", self.user.userId] parameters:[[HandshakeSession currentSession] credentials] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *contacts = [[NSMutableArray alloc] init];
        
        NSManagedObjectContext *objectContext = [[HandshakeCoreDataStore defaultStore] mainManagedObjectContext];
        
        for (NSDictionary *dict in responseObject[@"mutual"]) {
            // try to get contact
            
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Contact"];
            
            request.predicate = [NSPredicate predicateWithFormat:@"contactId == %@", dict[@"id"]];
            request.fetchLimit = 1;
            
            __block NSArray *results;
            
            [objectContext performBlockAndWait:^{
                results = [objectContext executeFetchRequest:request error:nil];
            }];
            
            if (results && [results count] == 1) {
                [contacts addObject:results[0]];
            }
        }
        
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"user.formattedName" ascending:YES];
        
        self.contacts = [[NSMutableArray alloc] initWithArray:[contacts sortedArrayUsingDescriptors:@[sort]]];
        self.loaded = YES;
        [self.tableView reloadData];
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
    cell.contact = self.contacts[indexPath.row - 1];
    [cell setDeleteBlock:^(void) {
        [self.contacts removeObject:cell.contact];
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
    
    Contact *contact = self.contacts[indexPath.row - 1];

    UserViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"UserViewController"];
    controller.user = contact.user;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
