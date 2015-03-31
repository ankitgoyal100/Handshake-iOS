//
//  CreateCardTutorialTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 10/15/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "CreateCardTutorialTableViewCell.h"

@interface CreateCardTutorialTableViewCell()

@property (nonatomic) UILabel *tutorialLabel;

@end

@implementation CreateCardTutorialTableViewCell

- (UILabel *)tutorialLabel {
    if (!_tutorialLabel) {
        _tutorialLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tutorialLabel.backgroundColor = [UIColor clearColor];
        _tutorialLabel.textColor = [UIColor lightGrayColor];
        _tutorialLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        _tutorialLabel.text = @"Tap '+' to create a new card.";
        _tutorialLabel.textAlignment = NSTextAlignmentCenter;
        _tutorialLabel.numberOfLines = 0;
        _tutorialLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _tutorialLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self addSubview:self.tutorialLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.tutorialLabel.frame = self.bounds;
}

- (float)preferredHeight {
    return 150;
}

@end
