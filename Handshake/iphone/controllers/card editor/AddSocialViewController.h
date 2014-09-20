//
//  AddSocialViewController.h
//  Handshake
//
//  Created by Sam Ober on 9/12/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "SectionBasedTableViewController.h"
#import "Card.h"

typedef void (^AddSocialSuccessBlock)();

@interface AddSocialViewController : SectionBasedTableViewController

- (id)initWithCard:(Card *)card successBlock:(AddSocialSuccessBlock)successBlock;

@end
