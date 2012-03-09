//
//  GridImageCell.h
//  ExpBkOffTest
//
//  Created by Carl Brown on 3/8/12.
//  Copyright (c) 2012 PDAgent, LLC. All rights reserved.
//

#import "AQGridViewCell.h"
@class Thumbnail;

@interface GridImageCell : AQGridViewCell

@property (strong, nonatomic) Thumbnail *thumbnail;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@end
