//
//  ContactCell.h
//  Handshake
//
//  Created by Sam Ober on 4/24/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface ContactCell : UITableViewCell

@property (weak, nonatomic) IBOutlet AsyncImageView *pictureView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
