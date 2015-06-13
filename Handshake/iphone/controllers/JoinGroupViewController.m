//
//  JoinGroupViewController.m
//  Handshake
//
//  Created by Sam Ober on 5/8/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "JoinGroupViewController.h"
#import "HandshakeSession.h"
#import "HandshakeClient.h"
#import "HandshakeCoreDataStore.h"
#import "Card.h"
#import "FeedItem.h"
#import "GroupServerSync.h"
#import "FeedItemServerSync.h"
#import "GroupCodeHelper.h"

@interface JoinGroupViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *joinButton;

@property (weak, nonatomic) IBOutlet UITextField *field1;
@property (weak, nonatomic) IBOutlet UITextField *field2;
@property (weak, nonatomic) IBOutlet UITextField *field3;
@property (weak, nonatomic) IBOutlet UITextField *field4;
@property (weak, nonatomic) IBOutlet UITextField *field5;
@property (weak, nonatomic) IBOutlet UITextField *field6;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) IBOutlet UIButton *pasteButton;

@end

@implementation JoinGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self checkForCode];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForCode) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.field1 becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)checkForCode {
    NSString *code = [GroupCodeHelper code];
    
    if (code) {
        NSString *formattedCode = [[NSString stringWithFormat:@"%@-%@-%@", [code substringToIndex:2], [code substringWithRange:NSMakeRange(2, 2)], [code substringFromIndex:4]] uppercaseString];
        
        NSMutableAttributedString *buttonTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Paste Code: %@", formattedCode] attributes:@{ NSFontAttributeName: [UIFont boldSystemFontOfSize:15], NSForegroundColorAttributeName: [UIColor whiteColor] }];
        [buttonTitle setAttributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:15], NSForegroundColorAttributeName: [UIColor whiteColor] } range:[buttonTitle.string rangeOfString:formattedCode]];
        
        [self.pasteButton setAttributedTitle:buttonTitle forState:UIControlStateNormal];
        self.pasteButton.hidden = NO;
    } else {
        self.pasteButton.hidden = YES;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    string = [string uppercaseString];
    
    if ([string length] == 0) {
        textField.text = @"";
        
        // shift characters
        for (int index = [self indexForField:textField]; index < 5; index++)
            [self fieldForIndex:index].text = [self fieldForIndex:index + 1].text;
        self.field6.text = @"";
        
        [[self fieldForIndex:MAX(0, [self indexForField:textField] - 1)] becomeFirstResponder];
        
        // special case for first field
        if (textField == self.field1)
            [self.field1 setSelectedTextRange:[self.field1 textRangeFromPosition:[self.field1 positionFromPosition:[self.field1 beginningOfDocument] offset:0] toPosition:[self.field1 positionFromPosition:[self.field1 beginningOfDocument] offset:0]]];
    } else if ([string length] == 1) {
        if ([[NSCharacterSet alphanumericCharacterSet] characterIsMember:[string characterAtIndex:0]]) {
            if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[string characterAtIndex:0]])
                for (int i = 0; i < 6; i++)
                    [self fieldForIndex:i].keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            else
                for (int i = 0; i < 6; i++)
                    [self fieldForIndex:i].keyboardType = UIKeyboardTypeDefault;
            
            if ([textField.text length] == 0) {
                textField.text = string;
            } else if (range.location == 0) { // replacing current field
                if ([self.field6.text length] == 0) {
                    // shift characters
                    for (int index = 5; index > [self indexForField:textField]; index--)
                        [self fieldForIndex:index].text = [self fieldForIndex:index - 1].text;
                    textField.text = string;
                }
            } else if (textField != self.field6 && [self.field6.text length] == 0) {
                // shift characters
                for (int index = 5; index > [self indexForField:textField] + 1; index--)
                    [self fieldForIndex:index].text = [self fieldForIndex:index - 1].text;
                
                UITextField *nextField = [self fieldForIndex:[self indexForField:textField] + 1];
                nextField.text = string;
                
                [nextField becomeFirstResponder];
            }
        }
    }
    
    [self checkCode];
    
    return NO;
}

- (int)indexForField:(UITextField *)textField {
    if (textField == self.field1) return 0;
    if (textField == self.field2) return 1;
    if (textField == self.field3) return 2;
    if (textField == self.field4) return 3;
    if (textField == self.field5) return 4;
    return 5;
}

- (UITextField *)fieldForIndex:(int)index {
    if (index == 0) return self.field1;
    if (index == 1) return self.field2;
    if (index == 2) return self.field3;
    if (index == 3) return self.field4;
    if (index == 4) return self.field5;
    return self.field6;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.joinButton.enabled)
        [self join:nil];
    
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField.text length] == 0) {
        for (int index = 5; index >= 0; index--) {
            UITextField *field = [self fieldForIndex:index];
            if ([field.text length] == 1) {
                [field becomeFirstResponder];
                return;
            }
        }
        
        [self.field1 becomeFirstResponder];
    }
}

- (NSString *)code {
    NSCharacterSet *set = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    NSString *code = [NSString stringWithFormat:@"%@%@%@%@%@%@", self.field1.text, self.field2.text, self.field3.text, self.field4.text, self.field5.text, self.field6.text];
    return [[[code componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""] lowercaseString];
}

- (void)checkCode {
    if ([[self code] length] == 6)
        self.joinButton.enabled = YES;
    else
        self.joinButton.enabled = NO;
}
- (IBAction)cancel:(id)sender {
    [self.view endEditing:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)join:(id)sender {
    self.joinButton.enabled = NO;
    [self.loadingView startAnimating];
    self.pasteButton.hidden = YES;
    [self.view endEditing:YES];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[HandshakeSession currentSession] credentials]];
    params[@"code"] = [self code];
    params[@"card_ids"] = @[((Card *)[[HandshakeSession currentSession] account].cards[0]).cardId];
    [[HandshakeClient client] POST:@"/groups/join" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // attempt to find group
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Group"];
        
        request.fetchLimit = 1;
        request.predicate = [NSPredicate predicateWithFormat:@"groupId == %@", responseObject[@"group"][@"id"]];
        
        __block NSArray *results;
        
        [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] performBlockAndWait:^{
            NSError *error;
            results = [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] executeFetchRequest:request error:&error];
        }];
        
        Group *group;
        
        if (results && [results count] == 1) {
            group = results[0];
        } else {
            group = [[Group alloc] initWithEntity:[NSEntityDescription entityForName:@"Group" inManagedObjectContext:[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext]] insertIntoManagedObjectContext:[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext]];
        }
        
        [group updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:responseObject[@"group"]]];
        group.syncStatus = [NSNumber numberWithInt:GroupSynced];
        
        [GroupServerSync syncWithCompletionBlock:^{
            [FeedItemServerSync sync];
        }];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(groupJoined:)])
            [self.delegate groupJoined:group];
        
        [self cancel:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.joinButton.enabled = YES;
        [self.loadingView stopAnimating];
        [self checkForCode];
        
        if ([[operation response] statusCode] == 401) {
            // invalidate session
            [[HandshakeSession currentSession] invalidate];
        } else if ([[operation response] statusCode] == 404) {
            [[[UIAlertView alloc] initWithTitle:@"Invalid Code" message:@"The code you entered does not match any existing groups." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not join group at this time. Please try again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

- (IBAction)paste:(id)sender {
    NSString *code = [GroupCodeHelper code];
    self.field1.text = [code substringToIndex:1];
    self.field2.text = [code substringWithRange:NSMakeRange(1, 1)];
    self.field3.text = [code substringWithRange:NSMakeRange(2, 1)];
    self.field4.text = [code substringWithRange:NSMakeRange(3, 1)];
    self.field5.text = [code substringWithRange:NSMakeRange(4, 1)];
    self.field6.text = [code substringWithRange:NSMakeRange(5, 1)];
    
    [self checkCode];
    [self.field6 becomeFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.field6 becomeFirstResponder];
}

@end
