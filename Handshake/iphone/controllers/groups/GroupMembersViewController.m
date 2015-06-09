//
//  GroupMembersViewController.m
//  Handshake
//
//  Created by Sam Ober on 5/7/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "GroupMembersViewController.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"
#import "AsyncImageView.h"
#import "HandshakeCoreDataStore.h"
#import "GroupMember.h"
#import "User.h"
#import "UserViewController.h"
#import "MemberCell.h"

@interface GroupMembersViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchController;

@end

@implementation GroupMembersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.navigationController && [self.navigationController.viewControllers indexOfObject:self] != 0)
        [self.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
    
    [self fetch];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)fetch {
    if (!self.group)
        return;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"GroupMember"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"group == %@", self.group];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"user.firstName" ascending:YES]];
    
    self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    
    self.fetchController.delegate = self;
    
    [self.fetchController.managedObjectContext performBlockAndWait:^{
        NSError *error;
        [self.fetchController performFetch:&error];
    }];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.fetchController fetchedObjects] count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) return [tableView dequeueReusableCellWithIdentifier:@"Separator"];
    
    User *user = ((GroupMember *)[self.fetchController fetchedObjects][indexPath.row - 1]).user;
    
    MemberCell *cell = (MemberCell *)[tableView dequeueReusableCellWithIdentifier:@"MemberCell"];
    
    if ([user cachedImage])
        cell.pictureView.image = [user cachedImage];
    else if (user.picture)
        cell.pictureView.imageURL = [NSURL URLWithString:user.picture];
    else
        cell.pictureView.image = [UIImage imageNamed:@"default_picture"];
    
    cell.nameLabel.text = [user formattedName];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) return 1;
    
    return 57;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) return;
    
    User *user = ((GroupMember *)[self.fetchController fetchedObjects][indexPath.row - 1]).user;
    
    UserViewController *controller = (UserViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"UserViewController"];
    controller.user = user;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
