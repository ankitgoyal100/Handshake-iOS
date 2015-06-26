//
//  TutorialViewController.m
//  Handshake
//
//  Created by Sam Ober on 6/18/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "TutorialViewController.h"
#import "AccountEditorViewController.h"
#import "Handshake.h"
#import "WelcomeViewController.h"
#import "ContactSync.h"
#import "ContactUploader.h"
#import "SuggestionsServerSync.h"
#import "UIControl+Blocks.h"
#import "NotificationsHelper.h"

@interface TutorialViewController ()

@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIButton *skipButton;
@property (nonatomic, strong) UIView *controlView;

@end

@implementation TutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // create next button
    
    self.controlView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.tabBar.frame.size.height + 1)];
    self.controlView.backgroundColor = [UIColor whiteColor];
    
    UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
    sep.backgroundColor = [UIColor grayColor];
    [self.controlView addSubview:sep];
    
    [self.view addSubview:self.controlView];
    
    self.nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.nextButton.frame = CGRectMake(self.view.frame.size.width - 120, 0, 100, self.controlView.frame.size.height);
    self.nextButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.nextButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [self.nextButton setTitleColor:LOGO_COLOR forState:UIControlStateNormal];
    
    [self.controlView addSubview:self.nextButton];
    
    self.skipButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.skipButton.frame = CGRectMake(20, 0, 100, self.controlView.frame.size.height);
    self.skipButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.skipButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.skipButton setTitle:@"Skip" forState:UIControlStateNormal];
    [self.skipButton setTitleColor:[UIColor colorWithWhite:0.8 alpha:1] forState:UIControlStateNormal];
    self.skipButton.hidden = YES;
    
    [self.controlView addSubview:self.skipButton];
    
    UINavigationController *nav = self.viewControllers[0];
    WelcomeViewController *welcomeController = nav.viewControllers[0];
    [welcomeController setGetStartedBlock:^{
        [self goToProfile];
    }];
}

- (void)goToProfile {
    UINavigationController *nav = self.viewControllers[0];
    
    // load account edit
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Edit" bundle:nil];
    AccountEditorViewController *controller = ((UINavigationController *)[storyboard instantiateInitialViewController]).viewControllers[0];
    controller.tutorialMode = YES;
    
    [nav pushViewController:controller animated:YES];
    [nav setNavigationBarHidden:NO animated:YES];
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.controlView.frame;
        frame.origin.y = self.view.frame.size.height - self.controlView.frame.size.height;
        self.controlView.frame = frame;
    }];
    
    __weak TutorialViewController *weakSelf = self;
    
    [self.nextButton addEventHandler:^(id sender) {
        [controller save];
        [weakSelf goToAddressBook];
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)goToAddressBook {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"address_book_permissions"]) { // already have permissions
        [self finish];
        return;
    }
    
    UINavigationController *nav = self.viewControllers[0];
    
    [nav pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"AddressBookViewController"] animated:YES];
    
    [self.nextButton setTitle:@"Allow Access" forState:UIControlStateNormal];
    
    __weak TutorialViewController *weakSelf = self;
    
    [self.nextButton addEventHandler:^(id sender) {
        [weakSelf requestAddressBookPermissions];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.skipButton addTarget:self action:@selector(finish) forControlEvents:UIControlEventTouchUpInside];
    self.skipButton.hidden = NO;
}

- (void)requestAddressBookPermissions {
    [ContactSync requestAddressBookAccessWithCompletionBlock:^(BOOL success) {
        [self finish];
    }];
}

- (void)finish {
    UINavigationController *nav = self.viewControllers[0];
    
    [nav pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"FinishingSetupViewController"] animated:YES];
    [nav setNavigationBarHidden:YES animated:YES];
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.controlView.frame;
        frame.origin.y = self.view.frame.size.height;
        self.controlView.frame = frame;
    }];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"last_contact_upload"];
    [defaults synchronize]; // reset last contact upload to ensure upload
    
    [ContactUploader uploadWithCompletionBlock:^{
        [SuggestionsServerSync syncWithCompletionBlock:^{
            [[NotificationsHelper sharedHelper] syncSettings];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            [self.view.window setRootViewController:[storyboard instantiateInitialViewController]];
        }];
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
