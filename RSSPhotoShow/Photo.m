//
//  Photo.m
//  RSSPhotoShow
//
//  Created by Erland Isaksson on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Photo.h"

@implementation Photo

@synthesize url = _url;
@synthesize title = _title;
@synthesize copyright = _copyright;
@synthesize link = _link;

-(id)initWithURL:(NSURL*)url {
    return [self initWithURL:url withTitle:nil];
}
-(id)initWithURL:(NSURL*)url withTitle:(NSString*)title {
    if(self = [super init]) {
        self.url = url;
        self.title = title;
    }
    return self;
}

@end
