//
//  LoadingTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/11/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "LoadingTableViewCell.h"

@interface LoadingTableViewCell()

@property (nonatomic) UIActivityIndicatorView *loadingView;

@end

@implementation LoadingTableViewCell

- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_loadingView startAnimating];
    }
    return _loadingView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self addSubview:self.loadingView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.loadingView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
}

- (float)preferredHeight {
    return 60;
}

@end
