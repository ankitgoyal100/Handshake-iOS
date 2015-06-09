//
//  UserHeaderCell.h
//  Handshake
//
//  Created by Sam Ober on 5/15/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "FXBlurView.h"

@interface UserHeaderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *contactsStatButton;
@property (weak, nonatomic) IBOutlet UIButton *mutualStatButton;

@property (weak, nonatomic) IBOutlet UIButton *primaryButton;
@property (weak, nonatomic) IBOutlet UIButton *secondaryButton;

@end
