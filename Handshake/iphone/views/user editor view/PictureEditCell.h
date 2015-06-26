//
//  PictureEditCell.h
//  Handshake
//
//  Created by Sam Ober on 6/4/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface PictureEditCell : UITableViewCell

@property (weak, nonatomic) IBOutlet AsyncImageView *pictureView;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end
