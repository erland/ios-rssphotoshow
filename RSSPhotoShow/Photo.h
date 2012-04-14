//
//  Photo.h
//  RSSPhotoShow
//
//  Created by Erland Isaksson on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Photo : NSObject
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *copyright;
@property (nonatomic, strong) NSURL *link;
-(id)initWithURL:(NSURL*)url;
-(id)initWithURL:(NSURL*)url withTitle:(NSString*)title;
@end
