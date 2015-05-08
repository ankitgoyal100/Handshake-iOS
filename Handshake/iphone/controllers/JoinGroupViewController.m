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

@interface JoinGroupViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *codeField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@end

@implementation JoinGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];

    [self checkCode];
    
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.saveButton.enabled)
        [self save:nil];
    
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.saveButton.enabled = NO;
    
    return YES;
}

- (NSString *)code {
    NSCharacterSet *set = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    return [[[self.codeField.text componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""] lowercaseString];
}

- (void)checkCode {
    if ([[self code] length] == 6)
        self.saveButton.enabled = YES;
    else
        self.saveButton.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.codeField becomeFirstResponder];
}

- (IBAction)cancel:(id)sender {
    [self.view endEditing:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    self.codeField.hidden = YES;
    [self.loadingView startAnimating];
    self.saveButton.enabled = NO;
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
        
        [Group sync];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(groupJoined:)])
            [self.delegate groupJoined:group];
        
        [self cancel:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.codeField.hidden = NO;
        [self.loadingView stopAnimating];
        self.saveButton.enabled = YES;
        
        NSLog(@"%@", [operation response]);
        
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.codeField becomeFirstResponder];
}

@end
