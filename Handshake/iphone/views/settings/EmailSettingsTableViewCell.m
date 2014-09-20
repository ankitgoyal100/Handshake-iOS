//
//  EmailSettingsTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/10/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "EmailSettingsTableViewCell.h"

@implementation EmailSettingsTableViewCell

- (UILabel *)emailLabel {
    if (!_emailLabel) {
        _emailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _emailLabel.backgroundColor = [UIColor clearColor];
        _emailLabel.textColor = [UIColor blackColor];
        _emailLabel.font = [UIFont systemFontOfSize:15];
    }
    return _emailLabel;
}

- (UIButton *)editButton {
    if (!_editButton) {
        _editButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _editButton.contentMode = UIViewContentModeCenter;
        [_editButton setImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
    }
    return _editButton;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self addSubview:self.emailLabel];
        [self addSubview:self.editButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.editButton sizeToFit];
    self.editButton.frame = CGRectMake(self.bounds.size.width - 10 - self.editButton.frame.size.width, 0, self.editButton.frame.size.width, self.bounds.size.height);
    self.emailLabel.frame = CGRectMake(10, 0, self.bounds.size.width - 20 - self.editButton.frame.size.width, self.bounds.size.height);
}

- (float)preferredHeight {
    return 57;
}

@end
