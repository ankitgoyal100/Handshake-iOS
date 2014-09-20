//
//  AddSocialViewController.m
//  Handshake
//
//  Created by Sam Ober on 9/12/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "AddSocialViewController.h"
#import "AddFacebookSection.h"
#import "AddTwitterSection.h"
#import "Social.h"

@interface AddSocialViewController()

@property (nonatomic, strong) Card *card;

@property (nonatomic, copy) AddSocialSuccessBlock successBlock;

@end

@implementation AddSocialViewController

- (id)initWithCard:(Card *)card successBlock:(AddSocialSuccessBlock)successBlock {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.card = card;
        self.successBlock = successBlock;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Add Social";
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    cancelButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    BOOL facebook = YES;
    for (Social *social in self.card.socials)
        if ([social.network isEqualToString:@"facebook"])
            facebook = NO;
    
    if (facebook) [self.sections addObject:[[AddFacebookSection alloc] initWithCard:self.card successBlock:^{
        self.successBlock();
    } viewController:self]];
    [self.sections addObject:[[AddTwitterSection alloc] initWithCard:self.card successBlock:^{
        self.successBlock();
    } viewController:self]];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
