//
//  RSSPhotoFetcher.h
//  RSSPhotoShow
//
//  Created by Erland Isaksson on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Photo.h"

@interface RSSPhotoFetcher : NSObject
-(NSArray *)fetchWithURL:(NSURL*)url;
@end
