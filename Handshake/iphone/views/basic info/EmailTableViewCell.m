//
//  EmailTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "EmailTableViewCell.h"

@implementation EmailTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIImageView *emailIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 30, 37)];
        emailIcon.image = [UIImage imageNamed:@"email.png"];
        emailIcon.contentMode = UIViewContentModeCenter;
        [self addSubview:emailIcon];
        
        self.emailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.emailLabel.backgroundColor = [UIColor clearColor];
        self.emailLabel.textColor = [UIColor blackColor];
        self.emailLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:self.emailLabel];
        
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
    
    self.emailLabel.frame = CGRectMake(50, 10, self.bounds.size.width - 60, 18);
    self.labelLabel.frame = CGRectMake(50, 33, self.bounds.size.width - 60, 14);
}

- (float)preferredHeight {
    return 57;
}

@end
