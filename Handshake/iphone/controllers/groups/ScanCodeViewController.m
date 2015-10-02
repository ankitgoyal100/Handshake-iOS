//
//  ScanCodeViewController.m
//  Handshake
//
//  Created by Sam Ober on 8/3/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "ScanCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "HandshakeSession.h"
#import "HandshakeCoreDataStore.h"
#import "HandshakeClient.h"
#import "GroupServerSync.h"
#import "Card.h"
#import "FeedItemServerSync.h"

#define TOOLBAR_HEIGHT      72.f
#define TOOLBAR_PADDING     10.f
#define HORIZONTAL_TEXT_PADDING 13.f

@interface ScanCodeViewController () <AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) IBOutlet UIView *toolbar;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@end

@implementation ScanCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // start reading
    
    NSError *error;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not access camera" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("capture_queue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    self.videoPreviewLayer.frame = self.viewPreview.bounds;
    [self.viewPreview.layer addSublayer:self.videoPreviewLayer];
    
    [self.captureSession startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = metadataObjects[0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self join:[metadataObj stringValue]];
            });
            [self.captureSession stopRunning];
        }
    }
}

- (void)join:(NSString *)code {
    self.toolbar.hidden = YES;
    [self.loadingView startAnimating];
    self.viewPreview.alpha = 0.7;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[HandshakeSession currentSession] credentials]];
    params[@"code"] = code;
    params[@"card_ids"] = @[((Card *)[[HandshakeSession currentSession] account].cards[0]).cardId];
    [[HandshakeClient client] POST:@"/groups/join" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [GroupServerSync cacheGroups:@[responseObject[@"group"]] completionsBlock:^(NSArray *groups) {
            Group *group = groups[0];
            
            [GroupServerSync loadGroupMembers:group completionBlock:^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(scanComplete:)])
                    [self.delegate scanComplete:group];
                
                [self cancel:nil];
            }];
            [FeedItemServerSync sync];
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.loadingView stopAnimating];
        
        if ([[operation response] statusCode] == 401) {
            // invalidate session
            [[HandshakeSession currentSession] invalidate];
        } else if ([[operation response] statusCode] == 404) {
            [[[UIAlertView alloc] initWithTitle:@"Invalid Code" message:@"This code does not match any existing groups." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not join group at this time. Please try again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

- (IBAction)cancel:(id)sender {
    [self.captureSession stopRunning];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
