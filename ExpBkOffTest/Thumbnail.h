//
//  Thumbnail.h
//  ExpBkOffTest
//
//  Created by Carl Brown on 3/8/12.
//  Copyright (c) 2012 PDAgent, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tag;

@interface Thumbnail : NSManagedObject

@property (nonatomic, retain) NSString * urlString;
@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) Tag *parentTag;

@end
