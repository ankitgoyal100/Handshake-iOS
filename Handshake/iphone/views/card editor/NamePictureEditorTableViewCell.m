//
//  NamePictureEditorTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "NamePictureEditorTableViewCell.h"
#import "FXBlurView.h"

@implementation NamePictureEditorTableViewCell

- (UIButton *)pictureButton {
    if (!_pictureButton) {
        _pictureButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 80, 80)];
        _pictureButton.layer.cornerRadius = 40;
        _pictureButton.layer.masksToBounds = YES;
        
        FXBlurView *blurView = [[FXBlurView alloc] initWithFrame:CGRectMake(0, 59, 80, 21)];
        blurView.blurRadius = 4;
        blurView.iterations = 3;
        //blurView.dynamic = YES;
        blurView.tintColor = [UIColor clearColor];
        blurView.userInteractionEnabled = NO;
        [_pictureButton addSubview:blurView];
        
        UIView *darkMask = [[UIView alloc] initWithFrame:blurView.frame];
        darkMask.backgroundColor = [UIColor blackColor];
        darkMask.alpha = 0.4;
        darkMask.userInteractionEnabled = NO;
        [_pictureButton addSubview:darkMask];
        
        UILabel *editLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 58, 80, 21)];
        editLabel.backgroundColor = [UIColor clearColor];
        editLabel.textColor = [UIColor whiteColor];
        editLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
        editLabel.textAlignment = NSTextAlignmentCenter;
        editLabel.text = @"EDIT";
        editLabel.userInteractionEnabled = NO;
        [_pictureButton addSubview:editLabel];
    }
    return _pictureButton;
}

- (UITextField *)firstNameField {
    if (!_firstNameField) {
        _firstNameField = [[UITextField alloc] initWithFrame:CGRectZero];
        _firstNameField.backgroundColor = [UIColor clearColor];
        _firstNameField.textColor = [UIColor blackColor];
        _firstNameField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:22];
        _firstNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _firstNameField.autocorrectionType = UITextAutocorrectionTypeNo;
        _firstNameField.placeholder = @"First";
    }
    return _firstNameField;
}

- (UITextField *)lastNameField {
    if (!_lastNameField) {
        _lastNameField = [[UITextField alloc] initWithFrame:CGRectZero];
        _lastNameField.backgroundColor = [UIColor clearColor];
        _lastNameField.textColor = [UIColor blackColor];
        _lastNameField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:22];
        _lastNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _lastNameField.autocorrectionType = UITextAutocorrectionTypeNo;
        _lastNameField.placeholder = @"Last";
    }
    return _lastNameField;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self addSubview:self.pictureButton];
        [self addSubview:self.firstNameField];
        [self addSubview:self.lastNameField];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.firstNameField.frame = CGRectMake(100, 22, self.bounds.size.width - 110, 25);
    self.lastNameField.frame = CGRectMake(100, 55, self.bounds.size.width - 110, 25);
}

- (float)preferredHeight {
    return 100;
}

@end
