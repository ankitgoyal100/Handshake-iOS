//
//  RequestsViewController.m
//  Handshake
//
//  Created by Sam Ober on 5/9/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "RequestsViewController.h"
#import "UserRequestCell.h"
#import "Request.h"
#import "HandshakeCoreDataStore.h"
#import "HandshakeClient.h"
#import "HandshakeSession.h"
#import "User.h"
#import "UIControl+Blocks.h"

@interface RequestsViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchController;

@end

@implementation RequestsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetch];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)fetch {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Request"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"user.userId != %@", [[HandshakeSession currentSession] account].userId];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];
    
    self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    
    self.fetchController.delegate = self;
    
    [self.fetchController.managedObjectContext performBlockAndWait:^{
        [self.fetchController performFetch:nil];
    }];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self fetch];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 1;
    
    if (section == 2) return 0;
    
    return [[self.fetchController fetchedObjects] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) return nil;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 32)];
    
    view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.95];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, self.view.frame.size.width - 32, view.frame.size.height)];
    
    label.font = [UIFont fontWithName:@"Roboto-Medium" size:14];
    label.textColor = [UIColor colorWithWhite:0.46 alpha:1];
    
    if (section == 1)
        label.text = @"Pending Approval";
    else
        label.text = @"People You May Know";
    
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
    
    if (section == 0 || section == 1) return 0;
    
    return 32;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) return [tableView dequeueReusableCellWithIdentifier:@"Spacer"];
    
    if (indexPath.row == [[self.fetchController fetchedObjects] count])
        return [tableView dequeueReusableCellWithIdentifier:@"Spacer"];
    
    Request *request = [self.fetchController fetchedObjects][indexPath.row];
    
    UserRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserRequestCell"];
    
    User *user = request.user;
    
    cell.pictureView.image = nil;
    if (user.pictureData)
        cell.pictureView.image = [UIImage imageWithData:user.pictureData];
    else if (user.picture)
        cell.pictureView.imageURL = [NSURL URLWithString:user.picture];
    else
        cell.pictureView.image = [UIImage imageNamed:@"default_picture"];
    
    cell.nameLabel.text = [user formattedName];
    if ([request.mutual intValue] == 1)
        cell.mutualFriendsLabel.text = @"1 mutual contact";
    else
        cell.mutualFriendsLabel.text = [NSString stringWithFormat:@"%d mutual contacts", [request.mutual intValue]];
    
    cell.acceptButton.hidden = NO;
    cell.declineButton.hidden = NO;
    
    [cell.acceptButton addEventHandler:^(id sender) {
        cell.acceptButton.hidden = YES;
        cell.declineButton.hidden = YES;
        
        cell.mutualFriendsLabel.text = @"Request accepted";
        
        [request acceptWithSuccessBlock:^(Contact *contact) {
            
        } failedBlock:^{
            [self.tableView reloadData];
            
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not accept request at this time. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [cell.declineButton addEventHandler:^(id sender) {
        cell.acceptButton.hidden = YES;
        cell.declineButton.hidden = YES;
        
        cell.mutualFriendsLabel.text = @"Request declined";
        
        [request deleteWithSuccessBlock:^{
            
        } failedBlock:^{
            [self.tableView reloadData];
            
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not decline request at this time. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    } forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 || indexPath.row == [[self.fetchController fetchedObjects] count])
        return 8;
    
    return 72;
}

- (IBAction)add:(id)sender {
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"] animated:YES];
}

@end
