//
//  LogoutTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/10/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "LogoutTableViewCell.h"

@interface LogoutTableViewCell()

@property (nonatomic) UILabel *logoutLabel;

@end

@implementation LogoutTableViewCell

- (UILabel *)logoutLabel {
    if (!_logoutLabel) {
        _logoutLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _logoutLabel.backgroundColor = [UIColor clearColor];
        _logoutLabel.textColor = [UIColor lightGrayColor];
        _logoutLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        _logoutLabel.textAlignment = NSTextAlignmentCenter;
        _logoutLabel.text = @"LOGOUT";
    }
    return _logoutLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.logoutLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.logoutLabel.frame = self.bounds;
}

- (float)preferredHeight {
    return 57;
}

@end
