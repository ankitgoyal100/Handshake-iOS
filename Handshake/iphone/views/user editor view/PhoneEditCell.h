//
//  PhoneEditCell.h
//  Handshake
//
//  Created by Sam Ober on 4/10/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhoneEditCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *labelLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end
