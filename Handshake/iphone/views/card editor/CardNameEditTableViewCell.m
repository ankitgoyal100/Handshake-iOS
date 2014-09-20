//
//  CardNameEditTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/10/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "CardNameEditTableViewCell.h"

@interface CardNameEditTableViewCell()

@property (nonatomic) UIImageView *cardNameIcon;

@end

@implementation CardNameEditTableViewCell

- (UIImageView *)cardNameIcon {
    if (!_cardNameIcon) {
        _cardNameIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        _cardNameIcon.contentMode = UIViewContentModeCenter;
        _cardNameIcon.image = [UIImage imageNamed:@"card_name.png"];
    }
    return _cardNameIcon;
}

- (UITextField *)cardNameField {
    if (!_cardNameField) {
        _cardNameField = [[UITextField alloc] initWithFrame:CGRectZero];
        _cardNameField.backgroundColor = [UIColor clearColor];
        _cardNameField.textColor = [UIColor blackColor];
        _cardNameField.font = [UIFont systemFontOfSize:15];
        _cardNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _cardNameField.placeholder = @"Name this card (ex. Personal)";
    }
    return _cardNameField;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self addSubview:self.cardNameIcon];
        [self addSubview:self.cardNameField];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.cardNameIcon.frame = CGRectMake(0, 0, 50, self.bounds.size.height);
    self.cardNameField.frame = CGRectMake(50, 0, self.bounds.size.width - 60, self.bounds.size.height);
}

- (float)preferredHeight {
    return 57;
}

@end
