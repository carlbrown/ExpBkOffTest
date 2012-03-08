//
//  Tag.m
//  ExpBkOffTest
//
//  Created by Carl Brown on 3/8/12.
//  Copyright (c) 2012 PDAgent, LLC. All rights reserved.
//

#import "Tag.h"
#import "AppDelegate.h"
#import "JSONKit.h"
#import "NSString+PDRegex.h"


@implementation Tag

@dynamic name;
@dynamic timeStamp;
@dynamic thumbnails;

-(void) fetch {
    NSURL *tagDownloadUrl = [NSURL URLWithString:BASE_URL_STRING([self name])];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queuePhotosForTagFromNotification:) name:kImageDownloadComplete object:tagDownloadUrl];
    
    NSURL *localJSONUrl= [[(AppDelegate *) [[UIApplication sharedApplication] delegate] assetManager] localURLForAssetURL:tagDownloadUrl];
    
    if (localJSONUrl) {
        [self queuePhotosForTagFromUrl:tagDownloadUrl];
    }

}

-(void) queuePhotosForTagFromUrl:(NSURL *) url {
    NSData *jsonData=[[(AppDelegate *) [[UIApplication sharedApplication] delegate] assetManager] dataForURL:url];
    if (jsonData) {
        NSError *error=nil;
        NSObject *obj = [jsonData objectFromJSONDataWithParseOptions:(JKParseOptionComments | JKParseOptionLooseUnicode | JKParseOptionPermitTextAfterValidJSON | JKParseOptionUnicodeNewlines) error:&error];
        if (obj==nil) {
            NSLog(@"Error parsing. Error was: %@",[error localizedDescription]);
            NSString *jsonString = [NSString stringWithUTF8String:[jsonData bytes]];
            NSLog(@"Got JSON String %@",jsonString);
            //Try to remove bad escapes
            // This is slow and painful, but what else can you do?
            //NSString *fixedJsonString=[jsonString stringByReplacingOccurrencesOfString:@"\\'" withString:@"'"];
            NSString *fixedJsonString=[jsonString stringByReplacingRegexPattern:@"\\\\(['])" withString:@"$1" caseInsensitive:NO treatAsOneLine:YES];
            obj = [fixedJsonString objectFromJSONStringWithParseOptions:(JKParseOptionComments | JKParseOptionLooseUnicode | JKParseOptionPermitTextAfterValidJSON | JKParseOptionUnicodeNewlines) error:&error];
            NSLog(@"Got object %@",obj);
        }
        //NSLog(@"Got object %@",obj);
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSMutableSet *urlSet = [[NSMutableSet alloc] init];
            NSArray *items = [(NSDictionary *) obj objectForKey:@"items"];
            for (NSDictionary *item in items) {
                if (item) {
                    NSDictionary *media = [item objectForKey:@"media"];
                    if (media) {
                        NSString *link = [media objectForKey:@"m"];
                        if (link) {
                            NSLog(@"Found link: '%@'",link);
                            NSURL *urlToQueue = [NSURL URLWithString:link];
                            if (urlToQueue) {
                                [urlSet addObject:urlToQueue];
                            }
                        }
                    }
                }
            }
            if ([urlSet count]>0) {
                [[(AppDelegate *) [[UIApplication sharedApplication] delegate] assetManager] queueAssetsForRetrievalFromURLSet:urlSet];
            }
            [urlSet release];
        }
    }    
}

-(void) queuePhotosForTagFromNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:kImageDownloadComplete]) {
        NSURL *url=[notification object];
        [self queuePhotosForTagFromUrl:url];
    }
    
}


@end
