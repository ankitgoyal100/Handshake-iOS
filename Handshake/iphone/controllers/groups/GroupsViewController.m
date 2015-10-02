//
//  GroupsViewController.m
//  Handshake
//
//  Created by Sam Ober on 5/3/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "GroupsViewController.h"
#import "GroupMember.h"
#import "HandshakeCoreDataStore.h"
#import "GroupView.h"
#import "UIControl+Blocks.h"
#import "GroupViewController.h"
#import "Group.h"
#import "EditGroupViewController.h"
#import "JoinGroupViewController.h"
#import "GroupServerSync.h"
#import "ContactServerSync.h"
#import "ScanCodeViewController.h"

@interface GroupsViewController () <NSFetchedResultsControllerDelegate, UIActionSheetDelegate, EditGroupViewControllerDelegate, JoinGroupViewControllerDelegate, ScanCodeViewControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchController;

@property (weak, nonatomic) IBOutlet UIView *groupCodeView;
@property (weak, nonatomic) IBOutlet UIView *textBoxView;

@property (weak, nonatomic) IBOutlet UITextField *groupCodeField;

@property (nonatomic, strong) NSAttributedString *tutorialString;

@end

@implementation GroupsViewController

- (NSAttributedString *)tutorialString {
    if (!_tutorialString) {
        NSMutableParagraphStyle *pStyle = [[NSMutableParagraphStyle alloc] init];
        [pStyle setLineSpacing:2];
        
        NSDictionary *attrs = @{ NSFontAttributeName: [UIFont systemFontOfSize:17], NSParagraphStyleAttributeName: pStyle, NSForegroundColorAttributeName: [UIColor colorWithWhite:0.5 alpha:1] };
        _tutorialString = [[NSAttributedString alloc] initWithString:@"Instantly share and receive contact information with entire groups of your friends!" attributes:attrs];
    }
    return _tutorialString;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect rect = self.groupCodeView.frame;
    rect.size.height = 0;//72;
    self.groupCodeView.frame = rect;
    self.groupCodeView.hidden = YES;
    
    // shadow for text box
    //self.textBoxView.layer.borderColor = [UIColor colorWithWhite:0.80 alpha:1].CGColor;
    //self.textBoxView.layer.borderWidth = 0.5;
    self.textBoxView.layer.shadowOffset = CGSizeMake(0, 1);
    self.textBoxView.layer.shadowRadius = 2;
    self.textBoxView.layer.shadowOpacity = 0.2;
    self.textBoxView.layer.cornerRadius = 2;
    
    [self fetch];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)fetch {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"syncStatus != %@", [NSNumber numberWithInt:GroupDeleted]];
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO]];
    
    self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    
    self.fetchController.delegate = self;
    
    [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] performBlockAndWait:^{
        NSError *error;
        [self.fetchController performFetch:&error];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[self.fetchController fetchedObjects] count] == 0) return 1;
    
    return [[self.fetchController fetchedObjects] count] / 2 + [[self.fetchController fetchedObjects] count] % 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.fetchController fetchedObjects] count] == 0) return [tableView dequeueReusableCellWithIdentifier:@"GroupsTutorialCell"];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    // remove all subviews
    for (UIView *view in cell.subviews)
        [view removeFromSuperview];
    
    for (int i = 0; i < 2; i++) {
        if (indexPath.row * 2 + i < [[self.fetchController fetchedObjects] count]) {
            __block Group *group = (Group *)[self.fetchController fetchedObjects][indexPath.row * 2 + i];
            
            int tileWidth = (self.view.frame.size.width / 2) - 10;
            GroupView *groupView = [[GroupView alloc] initWithFrame:CGRectMake((8 + i * 4) + tileWidth * i, (indexPath.row == 0 ? 8 : 4), tileWidth, 184)];
            groupView.group = group;
            [cell addSubview:groupView];
            
            if (group.code && ![group.code isEqualToString:@""]) {
                [groupView.button addEventHandler:^(id sender) {
                    if (!group)
                        return;
                    
                    GroupViewController *controller = (GroupViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"GroupViewController"];
                    controller.group = group;
                    [self.navigationController pushViewController:controller animated:YES];
                } forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
    
    return cell;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self fetch];
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.fetchController fetchedObjects] count] == 0) {
        CGRect frame = [self.tutorialString boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 48, 10000) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
        return frame.size.height + 48 + 36 + 30;
    }
    
    if (indexPath.row == 0) return 192;
    
    if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) return 196;
    
    return 188;
}

- (IBAction)add:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Enter Code", @"Scan Code", @"Create Group", nil];
    [sheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Scan Code"]) {
        ScanCodeViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ScanCodeViewController"];
        
        controller.delegate = self;
        
        [self presentViewController:controller animated:YES completion:nil];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Enter Code"]) {
        UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"JoinGroupViewController"];
        
        JoinGroupViewController *controller = nav.viewControllers[0];
        controller.delegate = self;
        
        [self presentViewController:nav animated:YES completion:nil];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Create Group"]) {
        [self createGroup:nil];
    }
}

- (IBAction)createGroup:(id)sender {
    EditGroupViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"EditGroupViewController"];
    controller.delegate = self;
    
    Group *group = [[Group alloc] initWithEntity:[NSEntityDescription entityForName:@"Group" inManagedObjectContext:[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext]] insertIntoManagedObjectContext:[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext]];
    group.syncStatus = [NSNumber numberWithInt:GroupDeleted]; // don't show in list
    controller.group = group;
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)groupEditCancelled:(Group *)group {
    [group.managedObjectContext deleteObject:group];
}

- (void)groupEdited:(Group *)group {
    group.createdAt = [NSDate date];
    group.syncStatus = [NSNumber numberWithInt:GroupCreated];
    [GroupServerSync sync];
}

- (void)groupJoined:(Group *)group {
    GroupViewController *controller = (GroupViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"GroupViewController"];
    controller.group = group;
    [self.navigationController pushViewController:controller animated:YES];
    
    [ContactServerSync sync];
}

- (void)scanComplete:(Group *)group {
    GroupViewController *controller = (GroupViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"GroupViewController"];
    controller.group = group;
    [self.navigationController pushViewController:controller animated:YES];
    
    [ContactServerSync sync];
}

@end
