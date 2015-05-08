//
//  MemberCell.h
//  Handshake
//
//  Created by Sam Ober on 5/7/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface MemberCell : UITableViewCell

@property (weak, nonatomic) IBOutlet AsyncImageView *pictureView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
