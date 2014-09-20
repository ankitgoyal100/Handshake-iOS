//
//  LabelEditableTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "LabelEditableTableViewCell.h"
#import "Handshake.h"

@interface LabelEditableTableViewCell()

@property (nonatomic) UIImageView *labelArrow;

@end

@implementation LabelEditableTableViewCell

- (UIButton *)labelButton {
    if (!_labelButton) {
        _labelButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_labelButton setTitleColor:LOGO_COLOR forState:UIControlStateNormal];
        _labelButton.titleLabel.font = [UIFont systemFontOfSize:11];
    }
    return _labelButton;
}

- (UIImageView *)labelArrow {
    if (!_labelArrow) {
        _labelArrow = [[UIImageView alloc] initWithFrame:CGRectZero];
        _labelArrow.image = [UIImage imageNamed:@"label_arrow.png"];
        _labelArrow.contentMode = UIViewContentModeCenter;
    }
    return _labelArrow;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.labelButton];
        [self addSubview:self.labelArrow];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.labelButton sizeToFit];
    self.labelButton.frame = CGRectMake(50, 0, self.labelButton.frame.size.width, self.bounds.size.height);
    
    self.labelArrow.frame = CGRectMake(self.labelButton.frame.origin.x + self.labelButton.frame.size.width + 2, 0, self.labelArrow.image.size.width, self.bounds.size.height);
}

- (void)setLabel:(NSString *)label {
    _label = label;
    
    [self.labelButton setTitle:label forState:UIControlStateNormal];
    [self setNeedsLayout];
}

@end
