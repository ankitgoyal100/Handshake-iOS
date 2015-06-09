//
//  ContactsCell.h
//  Handshake
//
//  Created by Sam Ober on 5/25/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *contactsLabel;
@property (weak, nonatomic) IBOutlet UILabel *mutualLabel;

@property (weak, nonatomic) IBOutlet UIButton *contactsButton;
@property (weak, nonatomic) IBOutlet UIButton *mutualButton;

@end
