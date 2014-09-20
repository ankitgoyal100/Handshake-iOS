//
//  MessageTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "MessageTableViewCell.h"

@interface MessageTableViewCell()

@property (nonatomic) UILabel *messageLabel;

@end

@implementation MessageTableViewCell

- (void)setMessage:(NSString *)message {
    _message = message;
    self.messageLabel.text = message;
}

- (id)initWithMessage:(NSString *)message reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.messageLabel.backgroundColor = [UIColor clearColor];
        self.messageLabel.font = [UIFont boldSystemFontOfSize:12];
        self.messageLabel.textColor = [UIColor grayColor];
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.messageLabel];
        
        self.message = message;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.messageLabel.frame = self.bounds;
}

- (float)preferredHeight {
    return 50;
}

@end
