//
//  GroupView.m
//  Handshake
//
//  Created by Sam Ober on 5/4/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "GroupView.h"
#import "AsyncImageView.h"
#import "GroupMember.h"
#import "User.h"
#import "UIControl+Blocks.h"

@interface GroupView()

@property (nonatomic, strong) NSMutableArray *imageViews;

@property (nonatomic, strong) UILabel *groupNameLabel;
@property (nonatomic, strong) UILabel *groupSizeLabel;

@property (nonatomic, strong) UILabel *codeLabel;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@end

@implementation GroupView

- (NSMutableArray *)imageViews {
    if (!_imageViews) _imageViews = [[NSMutableArray alloc] init];
    return _imageViews;
}

- (UILabel *)groupNameLabel {
    if (!_groupNameLabel) {
        _groupNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _groupNameLabel.font = [UIFont fontWithName:@"Roboto" size:16];
    }
    return _groupNameLabel;
}

- (UILabel *)groupSizeLabel {
    if (!_groupSizeLabel) {
        _groupSizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _groupSizeLabel.font = [UIFont fontWithName:@"Roboto" size:14];
        _groupSizeLabel.textColor = [UIColor grayColor];
    }
    return _groupSizeLabel;
}

- (UILabel *)codeLabel {
    if (!_codeLabel) {
        _codeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _codeLabel.font = [UIFont fontWithName:@"Roboto" size:15];
        _codeLabel.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        _codeLabel.textColor = [UIColor lightGrayColor];
        _codeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _codeLabel;
}

- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    return _loadingView;
}

- (UIButton *)button {
    if (!_button) {
        _button = [[UIButton alloc] initWithFrame:CGRectZero];
        //_button.backgroundColor = [UIColor clearColor];
        [_button setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateNormal];
        [_button setBackgroundImage:[UIImage imageNamed:@"button_press"] forState:UIControlStateHighlighted];
        
        _button.layer.masksToBounds = YES;
        _button.layer.zPosition = 1000;
        _button.layer.cornerRadius = 4;
    }
    return _button;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        //self.layer.borderWidth = 0.5;
        //self.layer.borderColor = [UIColor colorWithWhite:0.80 alpha:1].CGColor;
        //self.layer.shadowOffset = CGSizeMake(0, 1);
        ///self.layer.shadowOpacity = 0.2;
        //self.layer.shadowRadius = 2;
        self.layer.cornerRadius = 4;
        
        [self addSubview:self.groupNameLabel];
        [self addSubview:self.groupSizeLabel];
        
        [self addSubview:self.codeLabel];
        [self addSubview:self.loadingView];
        
        [self addSubview:self.button];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    self.group = self.group; // reset
}

- (void)setGroup:(Group *)group {
    _group = group;
    
    // reset all image views
    for (AsyncImageView *view in self.imageViews) {
        [view removeFromSuperview];
    }
    
    [self.imageViews removeAllObjects];
    
    self.groupSizeLabel.frame = CGRectMake(16, self.frame.size.height - 16 - 16, self.frame.size.width - 32, 18);
    if ([group.members count] == 1)
        self.groupSizeLabel.text = @"1 member";
    else
        self.groupSizeLabel.text = [NSString stringWithFormat:@"%d members", (int)[group.members count]];
    
    self.groupNameLabel.frame = CGRectMake(16, self.groupSizeLabel.frame.origin.y - 22, self.groupSizeLabel.frame.size.width, 22);
    self.groupNameLabel.text = group.name;
    
    if ([group.members count] > 0) {
        self.codeLabel.hidden = YES;
        [self.loadingView stopAnimating];
        
        int gridWidth = ((int)self.frame.size.width - 16) / 40;
        
        for (int y = 0; y < 2; y++) {
            for (int x = 0; x < gridWidth; x++) {
                if (y * gridWidth + x >= [group.members count])
                    break;
                
                GroupMember *member = [group.members allObjects][y * gridWidth + x];
                
                AsyncImageView *imageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(16 + x * 40, 16 + y * 40, 35, 35)];
                imageView.layer.masksToBounds = YES;
                imageView.layer.cornerRadius = 35.0 / 2.0;
                imageView.showActivityIndicator = NO;
                imageView.crossfadeDuration = 0;
                
                if (member.user.pictureData)
                    imageView.image = [UIImage imageWithData:member.user.pictureData];
                else if (member.user.picture && [member.user.picture length] > 0)
                    imageView.imageURL = [NSURL URLWithString:member.user.picture];
                else
                    imageView.image = [UIImage imageNamed:@"default.png"];
                imageView.userInteractionEnabled = NO;
                
                [self.imageViews addObject:imageView];
                [self addSubview:imageView];
            }
        }
    } else {
        self.codeLabel.frame = CGRectMake(16, 16, self.frame.size.width - 32, self.groupNameLabel.frame.origin.y - 32);
        
        if (!group.code || [group.code isEqualToString:@""]) {
            self.codeLabel.hidden = YES;
            self.loadingView.frame = self.codeLabel.frame;
            [self.loadingView startAnimating];
        } else {
            [self.loadingView stopAnimating];
            self.codeLabel.text = [NSString stringWithFormat:@"%@-%@-%@", [[group.code substringToIndex:2] uppercaseString], [[group.code substringWithRange:NSMakeRange(2, 2)] uppercaseString], [[group.code substringWithRange:NSMakeRange(4, 2)] uppercaseString]];
            self.codeLabel.hidden = NO;
        }
    }
    
    self.button.frame = self.bounds;
}

@end
