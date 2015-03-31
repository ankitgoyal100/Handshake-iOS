//
//  TermsViewController.m
//  Handshake
//
//  Created by Sam Ober on 10/14/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "TermsViewController.h"

@interface TermsViewController ()

@end

@implementation TermsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://gethandshakeapp.com/terms"]]];
    [self.view addSubview:webView];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    doneButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)done {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
