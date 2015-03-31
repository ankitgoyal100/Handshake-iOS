//
//  NamePictureEditorTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "NamePictureEditorTableViewCell.h"
#import "FXBlurView.h"

@interface NamePictureEditorTableViewCell()

@property (nonatomic) FXBlurView *editMask;

@end

@implementation NamePictureEditorTableViewCell

- (UIButton *)pictureButton {
    if (!_pictureButton) {
        _pictureButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 80, 80)];
        _pictureButton.layer.cornerRadius = 40;
        _pictureButton.layer.masksToBounds = YES;
        
        self.editMask = [[FXBlurView alloc] initWithFrame:CGRectMake(0, 59, 80, 21)];
        self.editMask.blurRadius = 4;
        self.editMask.iterations = 3;
        //blurView.dynamic = YES;
        self.editMask.tintColor = [UIColor clearColor];
        self.editMask.userInteractionEnabled = NO;
        self.editMask.dynamic = NO;
        //self.editMask.updateInterval = 2;
        [_pictureButton addSubview:self.editMask];
        
        UIView *darkMask = [[UIView alloc] initWithFrame:self.editMask.bounds];
        darkMask.backgroundColor = [UIColor blackColor];
        darkMask.alpha = 0.4;
        darkMask.userInteractionEnabled = NO;
        [self.editMask addSubview:darkMask];
        
        UILabel *editLabel = [[UILabel alloc] initWithFrame:self.editMask.bounds];
        editLabel.backgroundColor = [UIColor clearColor];
        editLabel.textColor = [UIColor whiteColor];
        editLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
        editLabel.textAlignment = NSTextAlignmentCenter;
        editLabel.text = @"EDIT";
        editLabel.userInteractionEnabled = NO;
        [self.editMask addSubview:editLabel];
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
        
        self.showsEditMask = YES;
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

- (void)setShowsEditMask:(BOOL)showsEditMask {
    _showsEditMask = showsEditMask;
    
    if (showsEditMask) {
        self.editMask.hidden = NO;
    } else {
        self.editMask.hidden = YES;
    }
}

- (void)setPicture:(UIImage *)image {
    [self.pictureButton setImage:image forState:UIControlStateNormal];
    [self.editMask updateAsynchronously:YES completion:nil];
}

@end
