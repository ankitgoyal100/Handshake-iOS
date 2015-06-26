//
//  WelcomeViewController.m
//  Handshake
//
//  Created by Sam Ober on 6/18/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "WelcomeViewController.h"
#import "HandshakeSession.h"

@interface WelcomeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *welcomeSubtextLabel;
@property (weak, nonatomic) IBOutlet UIButton *getStartedButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *welcomeLabelCenter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *welcomeSubtextCenter;

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.welcomeLabel.text = [NSString stringWithFormat:@"Welcome, %@!", [[HandshakeSession currentSession] account].firstName];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.4 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.welcomeLabelCenter.constant = 41;
        self.welcomeLabel.alpha = 1;
        [self.view layoutSubviews];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 delay:0.6 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.welcomeSubtextCenter.constant = -2;
            self.welcomeSubtextLabel.alpha = 1;
            [self.view layoutSubviews];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.4 delay:0.6 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.getStartedButton.alpha = 1;
            } completion:nil];
        }];
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)start:(id)sender {
    if (self.getStartedBlock) self.getStartedBlock();
}

@end
