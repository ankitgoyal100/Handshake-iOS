//
//  MessageTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 10/6/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "SetupMessageTableViewCell.h"

@interface SetupMessageTableViewCell()

@property (nonatomic) UILabel *messageLabel;

@end

@implementation SetupMessageTableViewCell

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.textColor = [UIColor grayColor];
        _messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.numberOfLines = 0;
        _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _messageLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self addSubview:self.messageLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.messageLabel.frame = CGRectMake(20, 0, self.bounds.size.width - 40, self.bounds.size.height);
}

- (float)preferredHeight {
    return 150;
}

- (void)setMessage:(NSString *)message {
    _message = message;
    
    self.messageLabel.text = message;
}

@end
