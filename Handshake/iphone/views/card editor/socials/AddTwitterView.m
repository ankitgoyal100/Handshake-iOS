//
//  AddTwitterView.m
//  Handshake
//
//  Created by Sam Ober on 9/13/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "AddTwitterView.h"

@interface AddTwitterView()

@property (nonatomic) UILabel *atLabel;

@end

@implementation AddTwitterView

- (UILabel *)atLabel {
    if (!_atLabel) {
        _atLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _atLabel.backgroundColor = [UIColor clearColor];
        _atLabel.textColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        _atLabel.font = [UIFont systemFontOfSize:30];
        _atLabel.textAlignment = NSTextAlignmentCenter;
        _atLabel.text = @"@";
    }
    return _atLabel;
}

- (UITextField *)usernameField {
    if (!_usernameField) {
        _usernameField = [[UITextField alloc] initWithFrame:CGRectZero];
        _usernameField.backgroundColor = [UIColor whiteColor];
        _usernameField.font = [UIFont systemFontOfSize:17];
        _usernameField.layer.cornerRadius = 10;
        _usernameField.layer.masksToBounds = YES;
        _usernameField.leftView = self.atLabel;//[[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
        _usernameField.leftViewMode = UITextFieldViewModeAlways;
        _usernameField.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
        _usernameField.rightViewMode = UITextFieldViewModeUnlessEditing;
        _usernameField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _usernameField.returnKeyType = UIReturnKeyDone;
        _usernameField.enablesReturnKeyAutomatically = YES;
        _usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    return _usernameField;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        //[self addSubview:self.atLabel];
        [self addSubview:self.usernameField];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //[self.atLabel sizeToFit];
    //self.atLabel.frame = CGRectMake(20, 0, self.atLabel.bounds.size.width, self.bounds.size.height);
    //self.usernameField.frame = CGRectMake(self.atLabel.bounds.size.width + 25, 0, self.bounds.size.width - self.atLabel.bounds.size.width - 45, self.bounds.size.height);
    
    self.atLabel.frame = CGRectMake(0, 0, 40, self.bounds.size.height);
    self.usernameField.frame = CGRectMake(20, 0, self.bounds.size.width - 40, self.bounds.size.height);
}

@end
