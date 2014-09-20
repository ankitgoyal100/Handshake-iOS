//
//  CardViewController.h
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "SectionBasedTableViewController.h"
#import "Card.h"

@interface CardViewController : SectionBasedTableViewController

- (id)initWithCard:(Card *)card;

@end
