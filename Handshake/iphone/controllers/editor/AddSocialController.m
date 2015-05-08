//
//  AddSocialController.m
//  Handshake
//
//  Created by Sam Ober on 4/20/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "AddSocialController.h"
#import "TwitterEditController.h"

@interface AddSocialController () <SocialEditControllerDelegate>

@end

@implementation AddSocialController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0 || indexPath.row == 3)
        return;
    
    if (indexPath.row == 2 && self.social) {
        // twitter
        TwitterEditController *controller = (TwitterEditController *)[self.storyboard instantiateViewControllerWithIdentifier:@"TwitterEditController"];
        controller.delegate = self;
        controller.social = self.social;
        
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (IBAction)cancel:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(socialEdited:)])
        [self.delegate socialEdited:self.social];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)socialEdited:(Social *)social {
    if (self.delegate && [self.delegate respondsToSelector:@selector(socialEdited:)])
        [self.delegate socialEdited:social];
}

@end
