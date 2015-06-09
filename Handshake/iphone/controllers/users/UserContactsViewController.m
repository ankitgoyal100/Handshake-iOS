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
#import "SearchResult.h"
#import "ContactCell.h"
#import "UserRequestCell.h"
#import "SearchResultCell.h"
#import "Request.h"
#import "Contact.h"
#import "UIControl+Blocks.h"
#import "UserViewController.h"

@interface UserContactsViewController ()

@property (nonatomic, strong) NSString *tag;

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
    
    self.tag = [NSString stringWithFormat:@"%d", rand()];
    
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // delete all accepted/deleted requests
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Request"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"(accepted == %@ OR removed == %@) AND requestId == nil", @(YES), @(YES)];
    
    __block NSArray *results;
    
    [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] performBlockAndWait:^{
        results = [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] executeFetchRequest:request error:nil];
    }];
    
    if (results) {
        for (Request *r in results) {
            [r.managedObjectContext deleteObject:r];
        }
    }
}

- (void)back {
    // delete all tagged search results
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"SearchResult"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"tag == %@", self.tag];
    
    __block NSArray *results;
    
    [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] performBlockAndWait:^{
        NSError *error;
        results = [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] executeFetchRequest:request error:&error];
    }];
    
    for (SearchResult *result in results) {
        if (result.request && result.request.user.userId == [[HandshakeSession currentSession] account].userId) {
            [result.managedObjectContext deleteObject:result.request]; // delete outgoing requests
        }
        
        [result.managedObjectContext deleteObject:result];
    }
    
    // save context
    
    [[HandshakeCoreDataStore defaultStore] saveMainContext];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)load {
    self.loaded = NO;
    
    [[HandshakeClient client] GET:[NSString stringWithFormat:@"/users/%@/contacts", self.user.userId] parameters:[[HandshakeSession currentSession] credentials] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *contacts = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dict in responseObject[@"contacts"]) {
            NSDictionary *resultDict = [HandshakeCoreDataStore removeNullsFromDictionary:dict];
            
            // find or create SearchResult
            
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"SearchResult"];
            request.predicate = [NSPredicate predicateWithFormat:@"user.userId == %@ AND tag == %@", resultDict[@"id"], self.tag];
            request.fetchLimit = 1;
            
            __block NSArray *results;
            
            [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] performBlockAndWait:^{
                NSError *error;
                results = [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] executeFetchRequest:request error:&error];
            }];
            
            SearchResult *searchResult;
            
            if (results && [results count] == 1) {
                searchResult = results[0];
            } else {
                searchResult = [[SearchResult alloc] initWithEntity:[NSEntityDescription entityForName:@"SearchResult" inManagedObjectContext:[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext]] insertIntoManagedObjectContext:[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext]];
            }
            
            [searchResult updateFromDictionary:resultDict];
            searchResult.tag = self.tag;
            
            [contacts addObject:searchResult];
        }
        
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"user.formattedName" ascending:YES];
        
        self.contacts = [contacts sortedArrayUsingDescriptors:@[sort]];
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
    
    SearchResult *result = self.contacts[indexPath.row - 1];
    
    if (result.contact && result.contact.managedObjectContext && [result.contact.syncStatus intValue] != ContactDeleted) {
        ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
        cell.contact = result.contact;
        [cell setDeleteBlock:^(void) {
            [self.tableView reloadData];
        }];
        return cell;
    }
    
    if (result.request && result.request.user.userId != [[HandshakeSession currentSession] account].userId) {
        UserRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserRequestCell"];
        cell.request = result.request;
        return cell;
    }
    
    SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultCell"];
    cell.result = result;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.loaded && [self.contacts count] > 0 && indexPath.row == 0) return 1;
    
    return 57;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) return;
    
    SearchResult *result = self.contacts[indexPath.row - 1];
    
    UserViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"UserViewController"];
    controller.user = result.user;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
