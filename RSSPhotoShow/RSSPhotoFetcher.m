//
//  RSSPhotoFetcher.m
//  RSSPhotoShow
//
//  Created by Erland Isaksson on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSSPhotoFetcher.h"

@interface RSSPhotoFetcher () <NSXMLParserDelegate>
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *mediaTitle;
@property (nonatomic, strong) NSString *credit;
@property (nonatomic, strong) NSString *copyright;
@property (nonatomic, strong) NSString *mediaCopyright;
@property (nonatomic, strong) NSString *description;
@property (nonatomic) BOOL collectCharacters;
@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, strong) NSMutableArray *mediaTitles;
@property (nonatomic, strong) NSMutableArray *copyrights;
@property (nonatomic, strong) NSMutableArray *mediaCopyrights;
@property (nonatomic, strong) NSMutableString *characters;
@property (nonatomic, strong) NSMutableArray *photos;
@end

@implementation RSSPhotoFetcher

@synthesize url = _url;
@synthesize link = _link;
@synthesize title = _title;
@synthesize mediaTitle = _mediaTitle;
@synthesize credit = _credit;
@synthesize copyright = _copyright;
@synthesize mediaCopyright = _mediaCopyright;
@synthesize description = _description;
@synthesize collectCharacters = _collectCharacters;
@synthesize titles = _titles;
@synthesize mediaTitles = _mediaTitles;
@synthesize copyrights = _copyrights;
@synthesize mediaCopyrights = _mediaCopyrights;
@synthesize characters = _characters;
@synthesize photos = _photos;

- (NSMutableArray *)photos {
    if(!_photos) {
        _photos = [NSMutableArray array];
    }
    return _photos;
}

- (NSMutableArray *)titles {
    if(!_titles) {
        _titles = [NSMutableArray array];
    }
    return _titles;
}

- (NSMutableArray *)mediaTitles {
    if(!_mediaTitles) {
        _mediaTitles = [NSMutableArray array];
    }
    return _mediaTitles;
}

- (NSMutableArray *)copyrights {
    if(!_copyrights) {
        _copyrights = [NSMutableArray array];
    }
    return _copyrights;
}

- (NSMutableArray *)mediaCopyrights {
    if(!_mediaCopyrights) {
        _mediaCopyrights = [NSMutableArray array];
    }
    return _mediaCopyrights;
}

- (NSMutableString *)characters {
    if(!_characters) {
        _characters = [[NSMutableString alloc]init];
    }
    return _characters;
}
- (NSArray*)fetchWithURL:(NSURL*)url 
{
    self.photos = nil;
    NSXMLParser * parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:self];
    if([parser parse]) {
        NSArray * result = self.photos;
        self.photos = nil;
        return result;
    }else {
        return [NSArray array];
    }
}

- (void)addImage:(NSString*)url withLink:(NSString*)link withTitle:(NSString*)title withMediaTitle:(NSString*)mediaTitle withCopyright:(NSString*)copyright withCredit:(NSString*)credit {
    
    Photo * photo;
    if(title && [title isEqualToString:@"no title"]) {
        title = nil;
    }
    if(mediaTitle && [mediaTitle isEqualToString:@"no title"]) {
        mediaTitle = nil;
    }
    if(title) {
        if(mediaTitle && ![title isEqualToString:mediaTitle]) {
            photo = [[Photo alloc]initWithURL: [NSURL URLWithString:url] withTitle: [title stringByAppendingFormat:@":%@",mediaTitle]];
        }else {
            photo = [[Photo alloc]initWithURL: [NSURL URLWithString:url] withTitle: title];
        }
    }else if(mediaTitle) {
        photo = [[Photo alloc]initWithURL: [NSURL URLWithString:url] withTitle: mediaTitle];
    }else {
        photo = [[Photo alloc]initWithURL: [NSURL URLWithString:url]];
    }
    if(copyright && credit) {
        photo.copyright = [copyright stringByAppendingFormat:@" (credit to: %@",credit];
    }else if(copyright) {
        photo.copyright = copyright;
    }else if(credit) {
        photo.copyright = copyright;
    }
    photo.link = [NSURL URLWithString:link];
    [self.photos addObject: photo];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if(([elementName isEqualToString:@"enclosure"] || [elementName isEqualToString:@"media:content"]) && [attributeDict objectForKey:@"url"] && 
       ([[attributeDict objectForKey:@"type"] isEqualToString:@"image/png"] ||
        [[attributeDict objectForKey:@"type"] isEqualToString:@"image/jpeg"] ||
        [[attributeDict objectForKey:@"url"] hasSuffix:@"jpg"] ||
        [[attributeDict objectForKey:@"url"] hasSuffix:@"jpeg"] ||
        [[attributeDict objectForKey:@"url"] hasSuffix:@"png"])) {
           
           
           self.url = [attributeDict objectForKey:@"url"];
           if([attributeDict objectForKey:@"rdf:about"]) {
               self.link = [attributeDict objectForKey:@"rdf:about"];
           }
       } else if([elementName isEqualToString:@"item"]) {
           self.description = nil;
           self.url = nil;
           
           if(self.title) {
               [self.titles addObject:self.title];
           }
           self.title = nil;
           
           if(self.mediaTitle) {
               [self.mediaTitles addObject:self.mediaTitle];
           }
           self.mediaTitle = nil;
           
           if(self.mediaCopyright) {
               [self.mediaCopyrights addObject:self.mediaCopyright];
           }
           self.mediaCopyright = nil;
           
           if(self.copyright) {
               [self.copyrights addObject:self.copyright];
           }
           self.copyright = nil;
       } else if([elementName isEqualToString:@"link"]) {
           self.collectCharacters = YES;
       } else if([elementName isEqualToString:@"title"]) {
           self.collectCharacters = YES;
       } else if([elementName isEqualToString:@"description"]) {
           self.collectCharacters = YES;
       } else if([elementName isEqualToString:@"media:title"]) {
           self.collectCharacters = YES;
       } else if([elementName isEqualToString:@"media:credit"]) {
           self.collectCharacters = YES;
       } else if([elementName isEqualToString:@"media:copyright"]) {
           self.collectCharacters = YES;
       } else if([elementName isEqualToString:@"copyright"]) {
           self.collectCharacters = YES;
       }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"title"]) {
        if(self.title) {
            [self.titles addObject:self.title];
        }
        self.title = [self.characters copy];
        [self.characters setString:@""];
        self.collectCharacters = NO;
    }else if([elementName isEqualToString:@"link"]) {
        self.link = [self.characters copy];
        [self.characters setString:@""];
        self.collectCharacters = NO;
    }else if([elementName isEqualToString:@"description"]) {
        self.description = [self.characters copy];
        [self.characters setString:@""];
        self.collectCharacters = NO;
    }else if([elementName isEqualToString:@"media:title"]) {
        if(self.mediaTitle) {
            [self.mediaTitles addObject:self.mediaTitle];
        }
        self.mediaTitle = [self.characters copy];
        [self.characters setString:@""];
        self.collectCharacters = NO;
    }else if([elementName isEqualToString:@"media:credit"]) {
        self.credit = [self.characters copy];
        [self.characters setString:@""];
        self.collectCharacters = NO;
    }else if([elementName isEqualToString:@"media:copyright"]) {
        if(self.mediaCopyright) {
            [self.mediaCopyrights addObject:self.mediaCopyright];
        }
        self.mediaCopyright = [self.characters copy];
        [self.characters setString:@""];
        self.collectCharacters = NO;
    }else if([elementName isEqualToString:@"copyright"]) {
        if(self.copyright) {
            [self.copyrights addObject:self.copyright];
        }
        self.copyright = [self.characters copy];
        [self.characters setString:@""];
        self.collectCharacters = NO;
    }else if([elementName isEqualToString:@"item"]) {
        NSMutableArray *multipleUrls = [NSArray array];
        NSMutableArray *multipleTitles = [NSArray array];
        
        if(!self.url && self.description) {
            NSRegularExpression * expression = [NSRegularExpression regularExpressionWithPattern:@".*?<img.*?src=\"(.*?)\"[^>]*title=\"(.*?)\".*?>.*" options:NSRegularExpressionCaseInsensitive
                                                                                           error:NULL];
            NSArray *matches = [expression matchesInString:self.description options:0 range:NSMakeRange(0, self.description.length)];
            for (NSTextCheckingResult *match in matches) {
                NSRange linkRange = [match rangeAtIndex:1];
                NSRange linkTitleRange = [match rangeAtIndex:2];
                if([[self.description substringWithRange:linkRange]rangeOfString:@"jpg"].location == NSNotFound ||
                   [[self.description substringWithRange:linkRange]rangeOfString:@"jpeg"].location == NSNotFound ||
                   [[self.description substringWithRange:linkRange]rangeOfString:@"png"].location == NSNotFound) {
                    
                    self.url = [self.description substringWithRange:linkRange];
                    self.title = [self.description substringWithRange:linkTitleRange];
                    [multipleUrls addObject:self.url];
                    [multipleTitles addObject:self.title];
                }
            }
            
            if(!self.url) {
                expression = [NSRegularExpression regularExpressionWithPattern:@".*?<img.*?src=\"(.*?)\".*?>.*?" options:NSRegularExpressionCaseInsensitive
                                                                         error:NULL];
                NSArray *matches = [expression matchesInString:self.description options:0 range:NSMakeRange(0, self.description.length)];
                for (NSTextCheckingResult *match in matches) {
                    NSRange linkRange = [match rangeAtIndex:1];

                    if([[self.description substringWithRange:linkRange]rangeOfString:@"jpg"].location == NSNotFound ||
                       [[self.description substringWithRange:linkRange]rangeOfString:@"jpeg"].location == NSNotFound ||
                       [[self.description substringWithRange:linkRange]rangeOfString:@"png"].location == NSNotFound) {
                        self.url = [self.description substringWithRange:linkRange];
                        [multipleUrls addObject:self.url];
                    }
                }
            }
        }
        if(self.url) {
            NSString *currentTitle = self.title;
            if(!currentTitle && self.titles.count>0) {
                currentTitle = [self.titles lastObject];
            }
            
            NSString *currentMediaTitle = self.mediaTitle;
            if(!currentMediaTitle && self.mediaTitles.count>0) {
                currentMediaTitle = [self.mediaTitles lastObject];
            }
            
            NSString *currentCopyright = self.mediaCopyright;
            if(!currentCopyright && self.mediaCopyrights.count>0) {
                currentCopyright = [self.mediaCopyrights lastObject];
            }
            if(!currentCopyright) {
                currentCopyright = self.copyright;
                if(!currentCopyright && self.copyrights.count>0) {
                    currentCopyright = [self.copyrights lastObject];
                }
            }
            
            if(multipleUrls.count>1) {
                if(multipleTitles.count>1) {
                    for (NSString * url in multipleUrls) {
                        [self addImage:url 
                              withLink:self.link 
                             withTitle:currentTitle 
                        withMediaTitle:[multipleTitles objectAtIndex:0] 
                         withCopyright:currentCopyright 
                            withCredit:self.credit];
                        
                        [multipleTitles removeObjectAtIndex:0];
                    }
                }else {
                    for (NSString * url in multipleUrls) {
                        [self addImage:url 
                              withLink:self.link 
                             withTitle:currentTitle 
                        withMediaTitle:currentMediaTitle 
                         withCopyright:currentCopyright 
                            withCredit:self.credit];
                    }
                }
            }else {
                [self addImage:self.url 
                      withLink:self.link 
                     withTitle:currentTitle 
                withMediaTitle:currentMediaTitle 
                 withCopyright:currentCopyright 
                    withCredit:self.credit];
            }
            
            if(self.title && self.titles.count>0) {
                self.title = self.titles.lastObject;
                [self.titles removeObject:self.title];
            }else {
                self.title = nil;
            }

            if(self.mediaTitle && self.mediaTitles.count>0) {
                self.mediaTitle = self.mediaTitles.lastObject;
                [self.mediaTitles removeObject:self.mediaTitle];
            }else {
                self.mediaTitle = nil;
            }

            if(self.mediaCopyright && self.mediaCopyrights.count>0) {
                self.mediaCopyright = self.mediaCopyrights.lastObject;
                [self.mediaCopyrights removeObject:self.mediaCopyright];
            }else {
                self.mediaCopyright = nil;
            }

        }
    }
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if(self.collectCharacters) {
        [self.characters appendString:string];
    }
}
@end
