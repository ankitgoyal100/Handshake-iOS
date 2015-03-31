//
//  ImageViewController.m
//  lynk
//
//  Created by Sam Ober on 8/26/13.
//  Copyright (c) 2013 lynk. All rights reserved.
//

#import "ImageViewController.h"
#import "AsyncImageView.h"

@interface ImageScrollView : UIScrollView
@end

@implementation ImageScrollView

- (void)layoutSubviews{
    [super layoutSubviews];
    
    UIView *zoomView = [self.delegate viewForZoomingInScrollView:self];
    
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = zoomView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    zoomView.frame = frameToCenter;
}

@end

@interface ImageViewController ()

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) AsyncImageView *imageView;

@end

@implementation ImageViewController

- (id)initWithImage:(UIImage *)image {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.image = image;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    ImageScrollView *scrollView = [[ImageScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.delegate = self;
    scrollView.clipsToBounds = NO;
    scrollView.decelerationRate = 0.0;
    scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scrollView];
    
    self.imageView = [[AsyncImageView alloc] initWithFrame:scrollView.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.backgroundColor = [UIColor blackColor];
    [scrollView addSubview:self.imageView];
    
    scrollView.minimumZoomScale = CGRectGetWidth(scrollView.frame) / CGRectGetWidth(self.imageView.frame);
    scrollView.maximumZoomScale = 20.0; 
    [scrollView setZoomScale:1.0];

    self.imageView.image = self.image;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
    [self.view addGestureRecognizer:tap];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)close {
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
