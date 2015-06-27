//
//  StartViewController.m
//  Handshake
//
//  Created by Sam Ober on 9/8/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "StartViewController.h"
#import "SignUpViewController.h"
#import "LogInViewController.h"
#import "HandshakeSession.h"
#import "MainViewController.h"
#import "FXBlurView.h"
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>

@interface StartViewController ()

@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIView *videoView;

@property (weak, nonatomic) IBOutlet UIImageView *background10View;
@property (weak, nonatomic) IBOutlet UIImageView *background20View;

@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;


@end

@implementation StartViewController

- (id)initWithLoading:(BOOL)loading {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _loading = loading;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loading = self.loading;
    
    // create video view
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"The-Boulevard" ofType:@"mp4"]]];
    [self.moviePlayer prepareToPlay];
    self.moviePlayer.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.moviePlayer.controlStyle = MPMovieControlStyleNone;
    self.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
    self.moviePlayer.repeatMode = MPMovieRepeatModeOne;
    [self.videoView addSubview:self.moviePlayer.view];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [super viewWillAppear:animated];
}

- (IBAction)signUp:(id)sender {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"SignUpViewController"];
    [self.navigationController pushViewController:controller animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (IBAction)logIn:(id)sender {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"LogInViewController"];
    [self.navigationController pushViewController:controller animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

//- (BOOL)prefersStatusBarHidden {
//    return YES;
//}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
