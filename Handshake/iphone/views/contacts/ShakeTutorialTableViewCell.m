//
//  ShakeTutorialTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 10/15/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "ShakeTutorialTableViewCell.h"

@interface ShakeTutorialTableViewCell()

@property (nonatomic) UIImageView *tutorialView;

@end

@implementation ShakeTutorialTableViewCell

- (UIImageView *)tutorialView {
    if (!_tutorialView) {
        _tutorialView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shake_tut.png"]];
        _tutorialView.contentMode = UIViewContentModeCenter;
    }
    return _tutorialView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.tutorialView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.tutorialView.frame = self.bounds;
}

- (float)preferredHeight {
    return 300;
}

@end
