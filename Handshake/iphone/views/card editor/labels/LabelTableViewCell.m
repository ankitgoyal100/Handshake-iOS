//
//  LabelTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/10/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "LabelTableViewCell.h"

@interface LabelTableViewCell()

@property (nonatomic) UILabel *labelLabel;
@property (nonatomic) UIImageView *selectedView;

@end

@implementation LabelTableViewCell

- (UILabel *)labelLabel {
    if (!_labelLabel) {
        _labelLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelLabel.backgroundColor = [UIColor clearColor];
        _labelLabel.textColor = [UIColor blackColor];
        _labelLabel.font = [UIFont systemFontOfSize:15];
    }
    return _labelLabel;
}

- (UIImageView *)selectedView {
    if (!_selectedView) {
        _selectedView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _selectedView.contentMode = UIViewContentModeCenter;
        _selectedView.image = [UIImage imageNamed:@"checked.png"];
        _selectedView.hidden = YES;
    }
    return _selectedView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.labelLabel];
        [self addSubview:self.selectedView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.labelLabel.frame = CGRectMake(10, 0, self.bounds.size.width - 20, self.bounds.size.height);
    
    self.selectedView.frame = CGRectMake(self.bounds.size.width - self.selectedView.image.size.width - 10, 0, self.selectedView.image
                                         .size.width, self.bounds.size.height);
}

- (float)preferredHeight {
    return 50;
}

- (void)setLabel:(NSString *)label {
    _label = label;
    
    self.labelLabel.text = label;
}

- (void)setSelectedOption:(BOOL)selected {
    if (selected)
        self.selectedView.hidden = NO;//self.selectedView.image = [UIImage imageNamed:@"checked.png"];
    else
        self.selectedView.hidden = YES;//self.selectedView.image = [UIImage imageNamed:@"unchecked.png"];
}

@end
