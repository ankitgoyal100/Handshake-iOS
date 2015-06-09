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
#import "FeedItem.h"
#import "GroupCodeCell.h"

@interface GroupViewController () <UIActionSheetDelegate, EditGroupViewControllerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *picturesView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *picturesViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *picturesViewTop;
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
        
        if ([user cachedImage])
            imageView.image = [user cachedImage];
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
    //self.picturesViewHeight.constant = MIN(100 - scrollView.contentOffset.y, 100);
    self.picturesViewTop.constant = MIN(-scrollView.contentOffset.y, 0);
    self.nameLabelConstraint.constant = MIN(62 - scrollView.contentOffset.y, 62);
   // self.picturesViewTop.constant = -scrollView.contentOffset.y;
    //self.nameLabelConstraint.constant = 62 - scrollView.contentOffset.y;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 100;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row == 0 || indexPath.row == 5)
//        return [tableView dequeueReusableCellWithIdentifier:@"Spacer"];
    
    if (indexPath.row == 0) {
        MembersCell *cell = (MembersCell *)[tableView dequeueReusableCellWithIdentifier:@"MembersCell"];
        if (self.group)
            cell.membersLabel.text = [NSString stringWithFormat:@"Members (%d)", (int)[self.group.members count]];
        return cell;
    }
    
    if (indexPath.row == 1)
        return [tableView dequeueReusableCellWithIdentifier:@"EditCell"];
    
    if (indexPath.row == 2) {
        GroupCodeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCodeCell"];
        
        cell.codeLabel.text = [[NSString stringWithFormat:@"%@-%@-%@", [self.group.code substringToIndex:2], [self.group.code substringWithRange:NSMakeRange(2, 2)], [self.group.code substringFromIndex:4]] uppercaseString];
        
        return cell;
    }
    
    if (indexPath.row == 2)
        return [tableView dequeueReusableCellWithIdentifier:@"EditCell"];
    
    return [tableView dequeueReusableCellWithIdentifier:@"LeaveCell"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //if (indexPath.row == 0) return 100 - 35;
    
    if (indexPath.row == 0) return 47;
    
    if (indexPath.row == 2) return 115;
    
    return 46;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        // members
        GroupMembersViewController *controller = (GroupMembersViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"GroupMembersViewController"];
        controller.group = self.group;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    if (indexPath.row == 1) {
        // edit name
        
        EditGroupViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"EditGroupViewController"];
        controller.group = self.group;
        controller.delegate = self;
        
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    if (indexPath.row == 3) {
        // leave group
        [[[UIActionSheet alloc] initWithTitle:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Leave Group" otherButtonTitles:nil] showFromTabBar:self.tabBarController.tabBar];
    }
}

- (void)groupEdited:(Group *)group {
    self.nameLabel.text = group.name;
    group.syncStatus = [NSNumber numberWithInt:GroupUpdated];
    
    [Group sync];
}

- (IBAction)options:(id)sender {
    [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Leave Group" otherButtonTitles:nil] showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Leave Group"]) {
        [[[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"You won't receive any new contacts from this group." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Leave", nil] show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Leave"]) {
        self.group.syncStatus = [NSNumber numberWithInt:GroupDeleted];
        for (FeedItem *item in self.group.feedItems)
            [self.group.managedObjectContext deleteObject:item];
        [Group sync];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
