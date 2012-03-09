//
//  Tag.m
//  ExpBkOffTest
//
//  Created by Carl Brown on 3/8/12.
//  Copyright (c) 2012 PDAgent, LLC. All rights reserved.
//

#import "Tag.h"
#import "Thumbnail.h"
#import "AppDelegate.h"
#import "JSONKit.h"
#import "NSString+PDRegex.h"
#import "ZSAssetManager.h"

@implementation Tag

@dynamic name;
@dynamic timeStamp;
@dynamic thumbnails;

-(void) fetch {
    NSURL *tagDownloadUrl = [NSURL URLWithString:BASE_URL_STRING([self name])];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queuePhotosForTagFromNotification:) name:kImageDownloadComplete object:tagDownloadUrl];
    
    NSURL *localJSONUrl= [[(AppDelegate *) [[UIApplication sharedApplication] delegate] assetManager]  localURLForAssetURL:tagDownloadUrl];
    
    if (localJSONUrl) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kImageDownloadComplete object:tagDownloadUrl];

        [self queuePhotosForTagFromUrl:tagDownloadUrl];
    } 
}

-(void) queuePhotosForTagFromUrl:(NSURL *) url {

    NSData *jsonData=[[(AppDelegate *) [[UIApplication sharedApplication] delegate] assetManager]  dataForURL:url];
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
            NSMutableOrderedSet *urlSet = [[NSMutableOrderedSet alloc] init];
            NSArray *items = [(NSDictionary *) obj objectForKey:@"items"];
            for (NSDictionary *item in items) {
                if (item) {
                    NSDictionary *media = [item objectForKey:@"media"];
                    if (media) {
                        NSString *link = [media objectForKey:@"m"];
                        if (link) {
                            NSLog(@"Found link: '%@'",link);
                            //This is the thumbnail URL, to make us take more bandwith (and thus test better)
                            //  use the full blown one

                            NSURL *urlToQueue = [NSURL URLWithString:[link stringByReplacingRegexPattern:@"_m\\." withString:@"."]];
                            if (urlToQueue) {                                
                                [urlSet addObject:urlToQueue];
                            }
                        }
                    }
                }
            }
            if ([urlSet count]>0) {
                [[(AppDelegate *) [[UIApplication sharedApplication] delegate] assetManager] queueAssetsForRetrievalFromURLSet:[urlSet set]];
                [self convertURLSetToThumbnails:urlSet];
                
            }
            [urlSet release];
        }
    }    
}

-(void) queuePhotosForTagFromNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:kImageDownloadComplete]) {

        NSURL *url=[notification object];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kImageDownloadComplete object:url];

        [self queuePhotosForTagFromUrl:url];
    }
    
}

-(void) convertURLSetToThumbnails:(NSOrderedSet *) urls {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Thumbnail" inManagedObjectContext:context];
    NSMutableOrderedSet *newThumbnails = [[NSMutableOrderedSet alloc] init];
    for (NSURL *url in urls) {
        Thumbnail *thumbnail = [[Thumbnail alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];
        [thumbnail setUrlString:[url absoluteString]];
        [newThumbnails addObject:thumbnail];
    }
    [self setThumbnails:newThumbnails];
    // Save the context.
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [newThumbnails release];
}


@end
