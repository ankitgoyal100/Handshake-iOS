//
//  JoinGroupDialogViewController.m
//  Handshake
//
//  Created by Sam Ober on 6/12/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "JoinGroupDialogViewController.h"
#import "AsyncImageView.h"

@interface JoinGroupDialogViewController ()

@property (weak, nonatomic) IBOutlet UIView *pictureView;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;

@property (strong, nonatomic) IBOutlet UIButton *cancelButton;

@property (nonatomic, strong) UIView *circleView;

@end

@implementation JoinGroupDialogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.promptLabel.text = [NSString stringWithFormat:@"Join %@?", self.groupName];
    
    float circleSize = self.pictureView.frame.size.height;
    
    self.circleView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - circleSize) / 2, 16, circleSize, circleSize)];
    self.circleView.layer.masksToBounds = YES;
    self.circleView.layer.cornerRadius = circleSize / 2;
    self.circleView.userInteractionEnabled = NO;
    self.circleView.layer.borderWidth = 0.5;
    self.circleView.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
    
    if (!self.picture2) {
        [self.circleView addSubview:[self createViewWithFrame:self.circleView.bounds picture:self.picture1]];
    } else if (!self.picture3) {
        [self.circleView addSubview:[self createViewWithFrame:CGRectMake(-0.5, 0, circleSize / 2, circleSize) picture:self.picture1]];
        [self.circleView addSubview:[self createViewWithFrame:CGRectMake(circleSize / 2 + 0.5, 0, circleSize / 2, circleSize) picture:self.picture2]];
    } else if (!self.picture4) {
        [self.circleView addSubview:[self createViewWithFrame:CGRectMake(-0.5, 0, circleSize / 2, circleSize) picture:self.picture1]];
        [self.circleView addSubview:[self createViewWithFrame:CGRectMake(circleSize / 2 + 0.5, -0.5, circleSize / 2, circleSize / 2) picture:self.picture2]];
        [self.circleView addSubview:[self createViewWithFrame:CGRectMake(circleSize / 2 + 0.5, circleSize / 2 + 0.5, circleSize / 2, circleSize / 2) picture:self.picture3]];
    } else {
        [self.circleView addSubview:[self createViewWithFrame:CGRectMake(-0.5, -0.5, circleSize / 2, circleSize / 2) picture:self.picture1]];
        [self.circleView addSubview:[self createViewWithFrame:CGRectMake(circleSize / 2 + 0.5, -0.5, circleSize / 2, circleSize / 2) picture:self.picture2]];
        [self.circleView addSubview:[self createViewWithFrame:CGRectMake(-0.5, circleSize / 2 + 0.5, circleSize / 2, circleSize / 2) picture:self.picture3]];
        [self.circleView addSubview:[self createViewWithFrame:CGRectMake(circleSize / 2 + 0.5, circleSize / 2 + 0.5, circleSize / 2, circleSize / 2) picture:self.picture4]];
    }
    
    [self.pictureView addSubview:self.circleView];
}

- (AsyncImageView *)createViewWithFrame:(CGRect)frame picture:(NSString *)picture {
    AsyncImageView *imageView = [[AsyncImageView alloc] initWithFrame:frame];
    imageView.showActivityIndicator = NO;
    imageView.crossfadeDuration = 0;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    
    imageView.imageURL = [NSURL URLWithString:picture];
    imageView.userInteractionEnabled = NO;
    
    return imageView;
}

- (IBAction)cancel:(id)sender {
    NSLog(@"%@", self);
    NSLog(@"%@", self.view);
    [self.view removeFromSuperview];
}

- (IBAction)join:(id)sender {
    [self cancel:nil];
}

@end
