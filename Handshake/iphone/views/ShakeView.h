//
//  ShakeView.h
//  Handshake
//
//  Created by Sam Ober on 10/5/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXBlurView.h"

typedef enum {
    ShakeLoadingStatus = 0,
    ShakeConfirmingStatus,
    ShakeWaitingConfirmationStatus
} ShakeStatus;

@interface ShakeView : FXBlurView

- (void)setPicture:(NSString *)picture;
- (void)setName:(NSString *)name;

@property (nonatomic) ShakeStatus shakeStatus;

@property (nonatomic) UIButton *stopShakeButton;

@property (nonatomic) UIButton *confirmButton;
@property (nonatomic) UIButton *cancelButton;

@end
