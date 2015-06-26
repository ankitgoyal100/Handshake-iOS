//
//  AddressBookViewController.m
//  Handshake
//
//  Created by Sam Ober on 6/20/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "AddressBookViewController.h"

@interface AddressBookViewController ()

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation AddressBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.hidesBackButton = YES;
    
    NSMutableParagraphStyle *pStyle = [[NSMutableParagraphStyle alloc] init];
    [pStyle setLineSpacing:2];
    
    NSDictionary *attrs = @{ NSFontAttributeName : [UIFont systemFontOfSize:15], NSParagraphStyleAttributeName : pStyle };
    NSAttributedString *message = [[NSAttributedString alloc] initWithString:@"Handshake needs to access your address book in order to sync contacts.\n\nWhenever you add new friends, Handshake downloads their contact information straight to your phone!\n\nHandshake also updates your contacts when friends make changes to their information." attributes:attrs];
    self.messageLabel.attributedText = message;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
