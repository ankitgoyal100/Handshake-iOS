//
//  MessageTableViewCell.h
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface MessageTableViewCell : BaseTableViewCell

- (id)initWithMessage:(NSString *)message reuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, strong) NSString *message;

@end
