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
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) NSArray * photos;
@property (nonatomic) NSInteger currentPhoto;
@property (weak, nonatomic) Photo *photo;
@property (strong, nonatomic) NSTimer * timer;
@property (strong, nonatomic) UITapGestureRecognizer *imageViewTouchRecognizer;
@property (strong, nonatomic) UISwipeGestureRecognizer *imageViewSwipeLeftRecognizer;
@property (strong, nonatomic) UISwipeGestureRecognizer *imageViewSwipeRightRecognizer;
@end

@implementation RSSPhotoShowViewController
@synthesize imageView = _imageView;
@synthesize titleLabel = _titleLabel;
@synthesize creditLabel = _creditLabel;
@synthesize toolbar = _toolbar;
@synthesize photos = _photos;
@synthesize currentPhoto = _currentPhoto;
@synthesize timer = _timer;
@synthesize imageViewTouchRecognizer = _imageViewTouchRecognizer;
@synthesize imageViewSwipeLeftRecognizer = _imageViewSwipeLeftRecognizer;
@synthesize imageViewSwipeRightRecognizer = _imageViewSwipeRightRecognizer;

- (Photo*)photo {
    if(self.currentPhoto && self.photos && self.photos.count>self.currentPhoto && self.currentPhoto>=0) {
        return [self.photos objectAtIndex:self.currentPhoto];
    }else {
        return nil;
    }
}
- (void)setPhoto:(Photo*)photo {
    [self.timer invalidate];
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
                                                          self.timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(switchImageThroughTimer:) userInfo:nil repeats:NO];
                                                      }];
                                 }
                             }];
        });
    });
}


-(NSArray *)shuffledArray:(NSArray*)array;
{
    
    NSMutableArray *shuffledArray = [NSMutableArray arrayWithCapacity:[array count]];
    
    NSMutableArray *copy = [array mutableCopy];
    while ([copy count] > 0)
    {
        int index = arc4random() % [copy count];
        id objectToMove = [copy objectAtIndex:index];
        [shuffledArray addObject:objectToMove];
        [copy removeObjectAtIndex:index];
    }
    
    return shuffledArray;
}

- (void)retrievePhotos {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *newPhotos = [[[RSSPhotoFetcher alloc]init] fetchWithURL:[NSURL URLWithString:@"http://feeds.feedburner.com/seanreiser/flickrinterestingness?format=xml"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = [self shuffledArray:newPhotos];
        });
    });
}

- (void)setPhotos:(NSArray*)photos {
    _photos = photos;
    self.currentPhoto = -1;
    [self switchImage:1];
}


- (void)switchImageThroughTimer:(NSTimer*)theTimer {
    [self switchImage:1];
}

- (void)switchImage:(NSInteger)increment {
    if(self.photos && self.photos.count>0) {
        self.currentPhoto+=increment;
        if((int)self.currentPhoto >= (int)self.photos.count) {
            self.currentPhoto = 0;
        }else if(self.currentPhoto<0) {
            self.currentPhoto = self.photos.count-1;
        }
        self.photo = [self.photos objectAtIndex:self.currentPhoto];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    [super viewDidAppear:animated];
    [self retrievePhotos];
    if(self.photos && self.photos.count>0) {
        [self switchImage:1];
    }else {
        self.titleLabel.text = @"Loading...";
        self.creditLabel.text = @"";
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    self.imageViewTouchRecognizer = 
    [[UITapGestureRecognizer alloc] initWithTarget:self 
                                            action:@selector(imageViewWasTouched:)];
    [self.imageView addGestureRecognizer:self.imageViewTouchRecognizer];

    self.imageViewSwipeLeftRecognizer = 
    [[UISwipeGestureRecognizer alloc] initWithTarget:self 
                                            action:@selector(nextImage:)];
    self.imageViewSwipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.imageView addGestureRecognizer:self.imageViewSwipeLeftRecognizer];

    self.imageViewSwipeRightRecognizer = 
    [[UISwipeGestureRecognizer alloc] initWithTarget:self 
                                              action:@selector(previousImage:)];
    self.imageViewSwipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.imageView addGestureRecognizer:self.imageViewSwipeRightRecognizer];
}
- (IBAction)nextImage:(id)sender {
    [self switchImage:1];
}
- (IBAction)previousImage:(id)sender {
    [self switchImage:-1];
}

- (void)imageViewWasTouched:(id)sender {
    if(self.toolbar.hidden) {
        self.toolbar.hidden = NO;
    }else {
        self.toolbar.hidden = YES;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.timer invalidate];
    self.timer = nil;
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
    [self.imageView removeGestureRecognizer:self.imageViewTouchRecognizer];
    [self.imageView removeGestureRecognizer:self.imageViewSwipeLeftRecognizer];
    [self.imageView removeGestureRecognizer:self.imageViewSwipeRightRecognizer];
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [self setTitleLabel:nil];
    [self setCreditLabel:nil];
    [self setToolbar:nil];
    [super viewDidUnload];
}
@end
