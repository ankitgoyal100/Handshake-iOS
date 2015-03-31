//
//  StartView.m
//  Handshake
//
//  Created by Sam Ober on 9/8/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "StartView.h"
#import "FXBlurView.h"
#import "Handshake.h"

@implementation StartView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundImage = [[UIImageView alloc] initWithFrame:self.bounds];
        self.backgroundImage.image = [UIImage imageNamed:@"start.jpg"];
        self.backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.backgroundImage];
        
        FXBlurView *blurView = [[FXBlurView alloc] initWithFrame:self.bounds];
        blurView.blurRadius = 1;
        blurView.iterations = 3;
        blurView.dynamic = NO;
        blurView.tintColor = [UIColor clearColor];
        [self addSubview:blurView];
        
        UIView *grayView = [[UIView alloc] initWithFrame:self.bounds];
        grayView.backgroundColor = [UIColor lightGrayColor];
        grayView.alpha = 0.7;
        [self addSubview:grayView];
        
//        UILabel *handshakeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height / 2 - 60, frame.size.width, 60)];
//        handshakeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:40];
//        handshakeLabel.text = @"Handshake";
//        handshakeLabel.textColor = [UIColor whiteColor];
//        handshakeLabel.backgroundColor = [UIColor clearColor];
//        handshakeLabel.textAlignment = NSTextAlignmentCenter;
//        [self addSubview:handshakeLabel];
        
        UIImageView *logoView = [[UIImageView alloc] initWithFrame:self.bounds];
        logoView.contentMode = UIViewContentModeCenter;
        logoView.image = [UIImage imageNamed:@"logo.png"];
        [self addSubview:logoView];
        
        self.signUpButton = [[UIButton alloc] initWithFrame:CGRectMake(20, self.bounds.size.height - 140, self.bounds.size.width - 40, 55)];
        self.signUpButton.backgroundColor = LOGO_COLOR;
        self.signUpButton.layer.cornerRadius = 27.5;
        [self.signUpButton setTitle:@"SIGN UP" forState:UIControlStateNormal];
        self.signUpButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
        [self addSubview:self.signUpButton];
        
        self.logInButton = [[UIButton alloc] initWithFrame:CGRectMake(20, self.bounds.size.height - 75, self.bounds.size.width - 40, 55)];
        self.logInButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        self.logInButton.layer.cornerRadius = 27.5;
        [self.logInButton setTitle:@"LOG IN" forState:UIControlStateNormal];
        self.logInButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
        [self addSubview:self.logInButton];
    }
    return self;
}

@end
