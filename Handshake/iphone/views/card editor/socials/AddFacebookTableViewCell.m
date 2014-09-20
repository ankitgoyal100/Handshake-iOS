//
//  AddFacebookTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/12/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "AddFacebookTableViewCell.h"

@interface AddFacebookTableViewCell()

@property (nonatomic) UIActivityIndicatorView *loadingView;

@end

@implementation AddFacebookTableViewCell

- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _loadingView.userInteractionEnabled = NO;
    }
    return _loadingView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.iconView.image = [UIImage imageNamed:@"facebook.png"];
        self.label.text = @"ADD FACEBOOK";
    }
    return self;
}

- (void)setName:(NSString *)name {
    _name = name;
    
    if (name) {
        self.label.textColor = [UIColor blackColor];
        self.label.font = [UIFont systemFontOfSize:15];
        self.label.text = name;
        self.addIcon.hidden = YES;
        [self setNeedsLayout];
    } else {
        // reset
        self.label = nil;
        [self addSubview:self.label];
        self.label.text = @"ADD FACEBOOK";
        self.addIcon.hidden = NO;
        [self setNeedsLayout];
    }
}

- (void)setLoading:(BOOL)loading {
    _loading = loading;
    
    if (loading) {
        [self.loadingView startAnimating];
        self.iconView.hidden = YES;
        self.label.hidden = YES;
    } else {
        [self.loadingView stopAnimating];
        self.iconView.hidden = NO;
        self.label.hidden = NO;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.loadingView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    
    if (self.name) {
        self.iconView.frame = CGRectMake(0, 0, 50, self.bounds.size.height);
        self.label.frame = CGRectMake(50, 0, self.bounds.size.width - 60, self.bounds.size.height);
    }
}

@end
