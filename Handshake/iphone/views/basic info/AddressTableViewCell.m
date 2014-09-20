//
//  AddressTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "AddressTableViewCell.h"

@interface AddressTableViewCell()

@property (nonatomic) UIImageView *addressIcon;

@end

@implementation AddressTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.addressIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 30, 37)];
        self.addressIcon.image = [UIImage imageNamed:@"address.png"];
        self.addressIcon.contentMode = UIViewContentModeCenter;
        [self addSubview:self.addressIcon];
        
        self.addressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.addressLabel.backgroundColor = [UIColor clearColor];
        self.addressLabel.textColor = [UIColor blackColor];
        self.addressLabel.font = [UIFont systemFontOfSize:15];
        self.addressLabel.numberOfLines = 0;
        self.addressLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:self.addressLabel];
        
        self.labelLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.labelLabel.backgroundColor = [UIColor clearColor];
        self.labelLabel.textColor = [UIColor lightGrayColor];
        self.labelLabel.font = [UIFont systemFontOfSize:11];
        [self addSubview:self.labelLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.addressIcon.frame = CGRectMake(10, 0, 30, self.bounds.size.height);
    
    self.addressLabel.frame = CGRectMake(50, 10, self.bounds.size.width - 60, 0);
    [self.addressLabel sizeToFit];
    
    self.labelLabel.frame = CGRectMake(50, self.addressLabel.frame.origin.y + self.addressLabel.frame.size.height + 5, self.bounds.size.width - 60, 14);
}

- (float)preferredHeight {
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrahStyle setLineSpacing:4];
    
    NSDictionary *attributesDictionary = @{ NSFontAttributeName: self.addressLabel.font, NSParagraphStyleAttributeName: paragrahStyle };
    CGRect frame = [self.address boundingRectWithSize:CGSizeMake(self.addressLabel.frame.size.width, 10000) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attributesDictionary context:nil];
    return MAX(57, 40 + frame.size.height);
}

- (void)setAddress:(NSString *)address {
    _address = address;
    
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrahStyle setLineSpacing:4];
    
    self.addressLabel.attributedText = [[NSAttributedString alloc] initWithString:address attributes:@{ NSParagraphStyleAttributeName: paragrahStyle }];
}

@end
