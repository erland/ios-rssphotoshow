//
//  RSSPhotoShowViewController.m
//  RSSPhotoShow
//
//  Created by Erland Isaksson on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSSPhotoShowViewController.h"
#import "RSSPhotoFetcher.h"

@interface RSSPhotoShowViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *creditLabel;
@property (strong, nonatomic) NSArray * photos;
@property (nonatomic) NSInteger currentPhoto;
@property (weak, nonatomic) Photo *photo;
@property (strong, nonatomic) NSTimer * timer;
@end

@implementation RSSPhotoShowViewController
@synthesize imageView = _imageView;
@synthesize titleLabel = _titleLabel;
@synthesize creditLabel = _creditLabel;
@synthesize photos = _photos;
@synthesize currentPhoto = _currentPhoto;
@synthesize timer = _timer;

- (Photo*)photo {
    if(self.currentPhoto && self.photos && self.photos.count>self.currentPhoto && self.currentPhoto>=0) {
        return [self.photos objectAtIndex:self.currentPhoto];
    }else {
        return nil;
    }
}
- (void)setPhoto:(Photo*)photo {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:photo.url];
        dispatch_async(dispatch_get_main_queue(),^{
            [UIView animateWithDuration:0.5 
                             animations:^{
                                 self.imageView.alpha = 0;
                                 self.titleLabel.alpha = 0;
                                 self.creditLabel.alpha = 0;
                             } 
                             completion:^(BOOL finished) {
                                 if(finished) {
                                     UIImage *image = [[UIImage alloc]initWithData:imageData];
                                     self.imageView.image = image;
                                     self.titleLabel.text = photo.title;
                                     self.creditLabel.text = photo.copyright;
                                     [UIView animateWithDuration:0.5 
                                                      animations:^{
                                                          self.imageView.alpha = 1;
                                                          self.titleLabel.alpha = 1;
                                                          self.creditLabel.alpha = 1;
                                                      }
                                                      completion:^(BOOL finished) {
                                                          self.timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(switchImage) userInfo:nil repeats:NO];
                                                      }];
                                 }
                             }];
        });
    });
}
- (void)retrievePhotos {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *newPhotos = [[[RSSPhotoFetcher alloc]init] fetchWithURL:[NSURL URLWithString:@"http://feeds.feedburner.com/seanreiser/flickrinterestingness?format=xml"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = newPhotos;
        });
    });
}

- (void)setPhotos:(NSArray*)photos {
    _photos = photos;
    self.currentPhoto = -1;
    [self switchImage];
}
- (void)switchImage {
    if(self.photos && self.photos.count>0) {
        self.currentPhoto++;
        if(self.currentPhoto >= self.photos.count) {
            self.currentPhoto = 0;
        }else if(self.currentPhoto<0) {
            self.currentPhoto = self.photos.count-1;
        }
        self.photo = [self.photos objectAtIndex:self.currentPhoto];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self retrievePhotos];
    if(self.photos && self.photos.count>0) {
        [self switchImage];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(switchImage) userInfo:nil repeats:YES];
    }else {
        self.titleLabel.text = @"Loading...";
        self.creditLabel.text = @"";
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [self setTitleLabel:nil];
    [self setCreditLabel:nil];
    [super viewDidUnload];
}
@end
