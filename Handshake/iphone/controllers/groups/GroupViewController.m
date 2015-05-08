//
//  GroupViewController.m
//  Handshake
//
//  Created by Sam Ober on 5/6/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "GroupViewController.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"
#import "AsyncImageView.h"
#import "GroupMember.h"
#import "User.h"
#import "GroupMembersViewController.h"
#import "MembersCell.h"
#import "EditGroupViewController.h"

@interface GroupViewController () <UIActionSheetDelegate, EditGroupViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *picturesView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *picturesViewHeight;
@property (weak, nonatomic) IBOutlet UIImageView *shadow;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelConstraint;

@property (nonatomic, strong) NSMutableArray *pictures;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation GroupViewController

- (NSMutableArray *)pictures {
    if (!_pictures) _pictures = [[NSMutableArray alloc] init];
    return _pictures;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.navigationController && [self.navigationController.viewControllers indexOfObject:self] != 0)
        [self.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
    
    if (self.group)
        self.group = self.group;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setGroup:(Group *)group {
    _group = group;
    
    if (!self.picturesView)
        return;
    
    self.nameLabel.text = group.name;
    
    for (AsyncImageView *imageView in self.pictures)
        [imageView removeFromSuperview];
    [self.pictures removeAllObjects];
    
    for (int i = 0; i < (int)self.view.frame.size.width / 100 + 1; i++) {
        if (i == [group.members count])
            break;
        
        AsyncImageView *imageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(i * 100, 0, 100, 100)];
        imageView.showActivityIndicator = NO;
        
        User *user = ((GroupMember *)[group.members allObjects][i]).user;
        
        if (user.pictureData)
            imageView.image = [UIImage imageWithData:user.pictureData];
        else if (user.picture)
            imageView.imageURL = [NSURL URLWithString:user.picture];
        else
            imageView.image = [UIImage imageNamed:@"default"];
        
        [self.picturesView addSubview:imageView];
        [self.pictures addObject:imageView];
    }
    
    [self.tableView reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.picturesViewHeight.constant = MIN(MAX(100 - scrollView.contentOffset.y, 70), 100);
    self.nameLabelConstraint.constant = MIN(MAX(46 - scrollView.contentOffset.y, 16), 46);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 || indexPath.row == 5)
        return [tableView dequeueReusableCellWithIdentifier:@"Spacer"];
    
    if (indexPath.row == 1) {
        MembersCell *cell = (MembersCell *)[tableView dequeueReusableCellWithIdentifier:@"MembersCell"];
        if (self.group)
            cell.membersLabel.text = [NSString stringWithFormat:@"Members (%d)", (int)[self.group.members count]];
        return cell;
    }
    
    if (indexPath.row == 2)
        return [tableView dequeueReusableCellWithIdentifier:@"SyncCell"];
    
    if (indexPath.row == 3)
        return [tableView dequeueReusableCellWithIdentifier:@"EditCell"];
    
    return [tableView dequeueReusableCellWithIdentifier:@"LeaveCell"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) return 108;
    
    if (indexPath.row == 5) return 8;
    
    return 56;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 1) {
        // members
        GroupMembersViewController *controller = (GroupMembersViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"GroupMembersViewController"];
        controller.group = self.group;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    if (indexPath.row == 3) {
        // edit name
        UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"EditGroupViewController"];
        
        EditGroupViewController *controller = nav.viewControllers[0];
        controller.group = self.group;
        controller.delegate = self;
        
        [self presentViewController:nav animated:YES completion:nil];
    }
    
    if (indexPath.row == 4) {
        // leave group
        [[[UIActionSheet alloc] initWithTitle:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Leave Group" otherButtonTitles:nil] showFromTabBar:self.tabBarController.tabBar];
    }
}

- (void)groupEdited:(Group *)group {
    self.nameLabel.text = group.name;
    group.syncStatus = [NSNumber numberWithInt:GroupUpdated];
    
    [Group sync];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Leave Group"]) {
        self.group.syncStatus = [NSNumber numberWithInt:GroupDeleted];
        [Group sync];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
