//
//  AddTwitterViewController.m
//  Handshake
//
//  Created by Sam Ober on 9/13/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "NewTwitterViewController.h"
#import "AddTwitterView.h"
#import "Handshake.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"
#import "Social.h"

@interface NewTwitterViewController() <UITextFieldDelegate>

@property (nonatomic, strong) Card *card;

@property (nonatomic) AddTwitterView *twitterView;

@property (nonatomic, copy) NewTwitterSuccessBlock successBlock;

@end

@implementation NewTwitterViewController

- (AddTwitterView *)twitterView {
    if (!_twitterView) {
        _twitterView = [[AddTwitterView alloc] initWithFrame:CGRectMake(0, 84, self.view.bounds.size.width, 50)];
    }
    return _twitterView;
}

- (id)initWithCard:(Card *)card successBlock:(NewTwitterSuccessBlock)successBlock {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.card = card;
        self.successBlock = successBlock;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = SUPER_LIGHT_GRAY;
    
    self.navigationItem.title = @"Add Twitter";
    
    if ([[self.navigationController viewControllers] indexOfObject:self] != 0) {
        [self.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
    }
    
    [self.view addSubview:self.twitterView];
    
    self.twitterView.usernameField.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.twitterView.usernameField becomeFirstResponder];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length == 0) return NO;
    
    Social *social = [[Social alloc] initWithEntity:[NSEntityDescription entityForName:@"Social" inManagedObjectContext:self.card.managedObjectContext] insertIntoManagedObjectContext:self.card.managedObjectContext];
    social.username = textField.text;
    social.network = @"twitter";
    [self.card addSocialsObject:social];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *twitters = [defaults mutableArrayValueForKey:@"recent_twitters"];
    for (NSString *twitter in twitters) {
        if ([twitter isEqualToString:textField.text])
            [twitters removeObject:twitter];
    }
    [twitters insertObject:textField.text atIndex:0];
    if ([twitters count] > 3) [twitters removeLastObject];
    [defaults synchronize];
    
    [self.view endEditing:YES];
    
    self.successBlock();
    
    return NO;
}

@end
