//
//  NSPCommentPhotoVC.m
//  NurserySmilesParent
//
//  Created by Adam Dossa on 19/04/2013.
//  Copyright (c) 2013 Adam Dossa. All rights reserved.
//

#import "NSPCommentPhotoVC.h"

@interface NSPCommentPhotoVC ()  <UIScrollViewDelegate>
@property (strong, nonatomic) UIImageView *imageView;
@end

@implementation NSPCommentPhotoVC
{
    UIActivityIndicatorView *spinner;
}


- (void)setPhoto:(PFFile *)photo
{
    _photo = photo;
    [self resetImage];
}

- (void)resetImage
{
    if (self.photoScrollView) {
        self.photoScrollView.contentSize = CGSizeZero;
        self.imageView.image = nil;
        PFFile *photo = self.photo;
        [spinner startAnimating];
        dispatch_queue_t q = dispatch_queue_create("image loading queue", NULL);
        dispatch_async(q, ^{
            UIApplication *myApplication = [UIApplication sharedApplication];
            myApplication.networkActivityIndicatorVisible = TRUE;
            UIImage *image = [UIImage imageWithData:[self.photo getData]];
            myApplication.networkActivityIndicatorVisible = FALSE;
            if (self.photo == photo) {
                // dispatch back to main queue to do UIKit work
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image) {
                        self.photoScrollView.zoomScale = 1.0;
                        self.photoScrollView.contentSize = image.size;
                        self.imageView.image = image;
                        self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                    }
                    [spinner stopAnimating];  // spinner should have hidesWhenStopped set
                });
            }

        });
    }
}

- (UIImageView *)imageView
{
    if (!_imageView) _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    return _imageView;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.photoScrollView addSubview:self.imageView];
    self.photoScrollView.minimumZoomScale = 0.2;
    self.photoScrollView.maximumZoomScale = 5.0;
    self.photoScrollView.delegate = self;
    spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    UIBarButtonItem *spinButton = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    [self.navigationItem setRightBarButtonItem:spinButton animated:YES];
    [self resetImage];
}
@end
