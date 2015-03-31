//
//  CardSetupViewController.m
//  Handshake
//
//  Created by Sam Ober on 10/6/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "CardSetupViewController.h"
#import "CardSetupSection.h"

@interface CardSetupViewController ()

@end

@implementation CardSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.sections insertObject:[[CardSetupSection alloc] initWithViewController:self] atIndex:0];
    
    self.navigationItem.hidesBackButton = YES;
    
    self.navigationItem.leftBarButtonItem = nil;
    
    self.navigationItem.rightBarButtonItem.title = @"Finish";
    self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStylePlain;
}

@end
