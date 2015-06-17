//
//  SuggestionsViewController.m
//  Handshake
//
//  Created by Sam Ober on 6/16/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "SuggestionsViewController.h"
#import "HandshakeCoreDataStore.h"
#import "Suggestion.h"
#import "User.h"
#import "SearchResultCell.h"
#import "UserViewController.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"
#import "SuggestionsServerSync.h"

@interface SuggestionsViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchController;

@end

@implementation SuggestionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Suggestions";
    
    if (self.navigationController && [self.navigationController.viewControllers indexOfObject:self] != 0)
        [self.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    [self fetch];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)fetch {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Suggestion"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"user.isContact == %@ AND user.requestReceived == %@ AND user.requestSent == %@", @(NO), @(NO), @(NO)];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"user.mutual" ascending:NO]];
    
    NSManagedObjectContext *objectContext = [[HandshakeCoreDataStore defaultStore] mainManagedObjectContext];
    
    self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:objectContext sectionNameKeyPath:nil cacheName:nil];
    
    self.fetchController.delegate = self;
    
    [objectContext performBlockAndWait:^{
        [self.fetchController performFetch:nil];
    }];
}

- (void)refresh {
    [SuggestionsServerSync syncWithCompletionBlock:^{
        [self fetch];
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    }];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self fetch];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1 + [[self.fetchController fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.fetchController fetchedObjects] count] == 0) return [tableView dequeueReusableCellWithIdentifier:@"NoResultsCell"];
    
    if (indexPath.row == 0) return [tableView dequeueReusableCellWithIdentifier:@"Separator"];
    
    Suggestion *suggestion = [self.fetchController fetchedObjects][indexPath.row - 1];
    
    SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultCell"];
    cell.user = suggestion.user;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.fetchController fetchedObjects] count] == 0) return 60;
    
    if (indexPath.row == 0) return 1;
    
    return 57;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) return;
    
    Suggestion *suggestion = [self.fetchController fetchedObjects][indexPath.row - 1];
    
    UserViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"UserViewController"];
    controller.user = suggestion.user;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
