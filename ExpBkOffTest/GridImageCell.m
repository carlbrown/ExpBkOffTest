//
//  GridImageCell.m
//  ExpBkOffTest
//
//  Created by Carl Brown on 3/8/12.
//  Copyright (c) 2012 PDAgent, LLC. All rights reserved.
//

#import "GridImageCell.h"
#import "AppDelegate.h"
#import "ZSAssetManager.h"
#import "Thumbnail.h"

@implementation GridImageCell

@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize imageView = _imageView;
@synthesize thumbnail = _thumbnail;

- (id) initWithFrame: (CGRect) frame reuseIdentifier: (NSString *) aReuseIdentifier
{
    self = [super initWithFrame: frame reuseIdentifier: aReuseIdentifier];
    if (self) {
        // Initialization code
        _imageView = [[UIImageView alloc] initWithFrame:frame];
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:frame];
        [_activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [_activityIndicatorView startAnimating];
        [self.contentView addSubview:_activityIndicatorView];
        [self addObserver:self forKeyPath:@"thumbnail" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    Thumbnail *newThumbnail = [self thumbnail];
    if (newThumbnail==nil) {
        return;
    }
    NSString *ourURLString = [newThumbnail urlString];
    NSURL *ourURL = [NSURL URLWithString:ourURLString];
    
    ZSAssetManager *assetManager = [(AppDelegate *) [[UIApplication sharedApplication] delegate] assetManager];
    UIImage *image = [assetManager imageForURL:ourURL];
    if (image==nil) {
        //Wait for the asset manager to fetch it for us
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupImageView:) name:kImageDownloadComplete object:ourURL];
    } else {
        [[self imageView] setImage:image];
        if ([[self activityIndicatorView] superview] != nil) {
            [[self activityIndicatorView] stopAnimating];
            [[self activityIndicatorView] removeFromSuperview];
        }
        if ([[self imageView] superview] == nil) {
            [[self imageView] setFrame:[[self contentView] frame]];
            [[self contentView] addSubview:[self imageView]];
        }
    }
}

-(void) setupImageView:(NSNotification *) notification {
    Thumbnail *newThumbnail = [self thumbnail];
    if (newThumbnail==nil) {
        return;
    }
    ZSAssetManager *am = [(AppDelegate *) [[UIApplication sharedApplication] delegate] assetManager];
    NSURL *ourURL = [NSURL URLWithString:[newThumbnail urlString]];
    UIImage *image = [am imageForURL:ourURL];
    if (image!=nil) {
        [[self imageView] setImage:image];
        if ([[self activityIndicatorView] superview] != nil) {
            [[self activityIndicatorView] stopAnimating];
            [[self activityIndicatorView] removeFromSuperview];
        }
        if ([[self imageView] superview] == nil) {
            [[self imageView] setFrame:[[self contentView] frame]];
            [[self contentView] addSubview:[self imageView]];
        }
    }

}

- (void) prepareForReuse {
    //Remove all observers (since we don't want to be notified of a URL that is no longer ours)
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [[self imageView] setImage:nil];
    [self setThumbnail:nil];
    
    if ([[self imageView] superview] != nil) {
        [[self imageView] removeFromSuperview];
    }
    
    if ([[self activityIndicatorView] superview] == nil) {
        [[self activityIndicatorView] setFrame:[[self contentView] frame]];
        [[self activityIndicatorView] startAnimating];
        [[self contentView] addSubview:[self activityIndicatorView]];
    }
    //Reinstate the observer on our own thumbnail property
    [self addObserver:self forKeyPath:@"thumbnail" options:NSKeyValueObservingOptionNew context:nil];

}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setImageView:nil];
    [self setActivityIndicatorView:nil];
    [self setThumbnail:nil];
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
