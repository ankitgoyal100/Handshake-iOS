//
//  AddSocialController.m
//  Handshake
//
//  Created by Sam Ober on 4/20/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "AddSocialController.h"
#import "TwitterEditController.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"

@interface AddSocialController () <SocialEditDelegate>

@end

@implementation AddSocialController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.navigationController && [self.navigationController.viewControllers indexOfObject:self] != 0)
        [self.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
}

- (void)back {
    if (self.delegate && [self.delegate respondsToSelector:@selector(socialEditCancelled:)])
        [self.delegate socialEditCancelled:self.social];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0 || indexPath.row == 3)
        return;
    
    if (indexPath.row == 1 && self.social) {
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
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
