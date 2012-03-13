//
//  Tag.h
//  ExpBkOffTest
//
//  Created by Carl Brown on 3/8/12.
//  Copyright (c) 2012 PDAgent, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Thumbnail;

@interface Tag : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSSet *thumbnails;

-(void) fetch;

@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)addThumbnailsObject:(Thumbnail *)value;
- (void)removeThumbnailsObject:(Thumbnail *)value;
- (void)addThumbnails:(NSSet *)values;
- (void)removeThumbnails:(NSSet *)values;


@end
