//
//  TermsViewController.m
//  Handshake
//
//  Created by Sam Ober on 10/14/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "TermsViewController.h"

@interface TermsViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation TermsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://gethandshakeapp.com/terms"]]];
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
