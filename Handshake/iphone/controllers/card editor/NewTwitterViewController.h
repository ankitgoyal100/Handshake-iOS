//
//  AddTwitterViewController.h
//  Handshake
//
//  Created by Sam Ober on 9/13/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"

typedef void (^NewTwitterSuccessBlock)();

@interface NewTwitterViewController : UIViewController

- (id)initWithCard:(Card *)card successBlock:(NewTwitterSuccessBlock)successBlock;

@end
