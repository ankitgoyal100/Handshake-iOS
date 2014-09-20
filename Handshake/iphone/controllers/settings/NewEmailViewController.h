//
//  NewEmailViewController.h
//  Handshake
//
//  Created by Sam Ober on 9/15/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^EmailUpdateSuccess)(NSString *email);

@interface NewEmailViewController : UIViewController

- (id)initWithEmail:(NSString *)email successBlock:(EmailUpdateSuccess)successBlock;

@end
