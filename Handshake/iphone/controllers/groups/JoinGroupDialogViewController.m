//
//  JoinGroupDialogViewController.m
//  Handshake
//
//  Created by Sam Ober on 6/12/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "JoinGroupDialogViewController.h"
#import "AsyncImageView.h"
#import "HandshakeSession.h"
#import "HandshakeClient.h"
#import "HandshakeCoreDataStore.h"
#import "Group.h"
#import "Card.h"
#import "GroupServerSync.h"
#import "FeedItemServerSync.h"

@interface JoinGroupDialogViewController ()

@property (strong, nonatomic) IBOutlet UIView *dialogView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *dialogCenter;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@property (weak, nonatomic) IBOutlet UIView *pictureView;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;

@property (strong, nonatomic) IBOutlet UIButton *cancelButton;

@property (strong, nonatomic) IBOutlet UIButton *joinButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *joinLoader;

@property (nonatomic, strong) UIView *circleView;

@end

@implementation JoinGroupDialogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self checkCode];
}

- (void)checkCode {
    // check with server
    [[HandshakeClient client] GET:[NSString stringWithFormat:@"/groups/find/%@", self.groupCode] parameters:[[HandshakeSession currentSession] credentials] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        responseObject = [HandshakeCoreDataStore removeNullsFromDictionary:responseObject];
        
        self.promptLabel.text = [NSString stringWithFormat:@"Want to join %@?", responseObject[@"group"][@"name"]];
        
        int numMembers = [responseObject[@"group"][@"members"] count];
        
        if (self.circleView)
            [self.circleView removeFromSuperview];
        
        float circleSize = self.pictureView.frame.size.height;
        
        self.circleView = [[UIView alloc] initWithFrame:CGRectMake((self.pictureView.frame.size.width - circleSize) / 2, 0, circleSize, circleSize)];
        self.circleView.layer.masksToBounds = YES;
        self.circleView.layer.cornerRadius = circleSize / 2;
        self.circleView.userInteractionEnabled = NO;
        self.circleView.layer.borderWidth = 0.5;
        self.circleView.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
        
        if (numMembers == 1) {
            [self.circleView addSubview:[self createViewWithFrame:self.circleView.bounds picture:responseObject[@"group"][@"members"][0][@"thumb"]]];
        } else if (numMembers == 2) {
            [self.circleView addSubview:[self createViewWithFrame:CGRectMake(-0.5, 0, circleSize / 2, circleSize) picture:responseObject[@"group"][@"members"][0][@"thumb"]]];
            [self.circleView addSubview:[self createViewWithFrame:CGRectMake(circleSize / 2 + 0.5, 0, circleSize / 2, circleSize) picture:responseObject[@"group"][@"members"][1][@"thumb"]]];
        } else if (numMembers == 3) {
            [self.circleView addSubview:[self createViewWithFrame:CGRectMake(-0.5, 0, circleSize / 2, circleSize) picture:responseObject[@"group"][@"members"][0][@"thumb"]]];
            [self.circleView addSubview:[self createViewWithFrame:CGRectMake(circleSize / 2 + 0.5, -0.5, circleSize / 2, circleSize / 2) picture:responseObject[@"group"][@"members"][1][@"thumb"]]];
            [self.circleView addSubview:[self createViewWithFrame:CGRectMake(circleSize / 2 + 0.5, circleSize / 2 + 0.5, circleSize / 2, circleSize / 2) picture:responseObject[@"group"][@"members"][2][@"thumb"]]];
        } else {
            [self.circleView addSubview:[self createViewWithFrame:CGRectMake(-0.5, -0.5, circleSize / 2, circleSize / 2) picture:responseObject[@"group"][@"members"][0][@"thumb"]]];
            [self.circleView addSubview:[self createViewWithFrame:CGRectMake(circleSize / 2 + 0.5, -0.5, circleSize / 2, circleSize / 2) picture:responseObject[@"group"][@"members"][1][@"thumb"]]];
            [self.circleView addSubview:[self createViewWithFrame:CGRectMake(-0.5, circleSize / 2 + 0.5, circleSize / 2, circleSize / 2) picture:responseObject[@"group"][@"members"][2][@"thumb"]]];
            [self.circleView addSubview:[self createViewWithFrame:CGRectMake(circleSize / 2 + 0.5, circleSize / 2 + 0.5, circleSize / 2, circleSize / 2) picture:responseObject[@"group"][@"members"][3][@"thumb"]]];
        }
        
        [self.pictureView addSubview:self.circleView];
        
        [self.loadingView stopAnimating];
        [UIView animateWithDuration:0.3 animations:^{
            self.dialogCenter.constant = 10;
            self.dialogView.alpha = 1;
            
            [self.view layoutIfNeeded];
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.view removeFromSuperview];
    }];
}

- (AsyncImageView *)createViewWithFrame:(CGRect)frame picture:(NSString *)picture {
    AsyncImageView *imageView = [[AsyncImageView alloc] initWithFrame:frame];
    imageView.showActivityIndicator = NO;
    imageView.crossfadeDuration = 0;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    
    if (picture)
        imageView.imageURL = [NSURL URLWithString:picture];
    else
        imageView.image = [UIImage imageNamed:@"default_picture"];
    imageView.userInteractionEnabled = NO;
    
    return imageView;
}

- (IBAction)cancel:(id)sender {
    [UIView animateWithDuration:0.2 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

- (IBAction)join:(id)sender {
    self.joinButton.hidden = YES;
    [self.joinLoader startAnimating];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[HandshakeSession currentSession] credentials]];
    params[@"code"] = self.groupCode;
    params[@"card_ids"] = @[((Card *)[[HandshakeSession currentSession] account].cards[0]).cardId];
    [[HandshakeClient client] POST:@"/groups/join" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [GroupServerSync cacheGroups:@[responseObject[@"group"]] completionsBlock:^(NSArray *groups) {
            Group *group = groups[0];
            
            [GroupServerSync loadGroupMembers:group completionBlock:nil];
            [FeedItemServerSync sync];
            
            [self cancel:nil];
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self cancel:nil];
    }];
}

@end
