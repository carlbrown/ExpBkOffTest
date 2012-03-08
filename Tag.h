//
//  Tag.h
//  ExpBkOffTest
//
//  Created by Carl Brown on 3/8/12.
//  Copyright (c) 2012 PDAgent, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Tag : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSOrderedSet *thumbnails;
@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)insertObject:(NSManagedObject *)value inThumbnailsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromThumbnailsAtIndex:(NSUInteger)idx;
- (void)insertThumbnails:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeThumbnailsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInThumbnailsAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceThumbnailsAtIndexes:(NSIndexSet *)indexes withThumbnails:(NSArray *)values;
- (void)addThumbnailsObject:(NSManagedObject *)value;
- (void)removeThumbnailsObject:(NSManagedObject *)value;
- (void)addThumbnails:(NSOrderedSet *)values;
- (void)removeThumbnails:(NSOrderedSet *)values;

-(void) queuePhotosForTagFromUrl:(NSURL *) localURL;
-(void) fetch;
-(void) convertURLSetToThumbnails:(NSOrderedSet *) urls;

@end
