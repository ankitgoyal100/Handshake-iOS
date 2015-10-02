//
//  ScanCodeViewController.h
//  Handshake
//
//  Created by Sam Ober on 8/3/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"

@protocol ScanCodeViewControllerDelegate <NSObject>

- (void)scanComplete:(Group *)group;

@end

@interface ScanCodeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *viewPreview;

@property (nonatomic, strong) id <ScanCodeViewControllerDelegate> delegate;

@end
