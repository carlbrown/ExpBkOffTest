//
//  DetailViewController.h
//  ExpBkOffTest
//
//  Created by Carl Brown on 2/28/12.
//  Copyright (c) 2012 PDAgent, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AQGridViewController.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, AQGridViewDelegate, AQGridViewDataSource>

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@property (strong, nonatomic) IBOutlet AQGridView *gridView;

@end
