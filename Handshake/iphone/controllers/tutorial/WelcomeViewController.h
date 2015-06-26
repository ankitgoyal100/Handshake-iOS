//
//  WelcomeViewController.h
//  Handshake
//
//  Created by Sam Ober on 6/18/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^GetStartedBlock)();

@interface WelcomeViewController : UIViewController

@property (nonatomic, copy) GetStartedBlock getStartedBlock;

@end
