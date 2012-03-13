//
//  DetailViewController.m
//  ExpBkOffTest
//
//  Created by Carl Brown on 2/28/12.
//  Copyright (c) 2012 PDAgent, LLC. All rights reserved.
//

#import "DetailViewController.h"
#import "Tag.h"
#import "GridImageCell.h"
#import "AQGridView.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

@synthesize detailItem = _detailItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize gridView = _gridView;
@synthesize fetchedResultsController = __fetchedResultsController;

- (void)dealloc
{
    [_detailItem release];
    [_detailDescriptionLabel release];
    [_masterPopoverController release];
    [super dealloc];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{    
    if (_detailItem != newDetailItem) {
        [_detailItem release];
        _detailItem = [newDetailItem retain];
        __fetchedResultsController = nil; //reset the fetched results controller

        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"name"] description];
    }
    
    //Note - the AQGridView doesn't listed to viewDidLoad or anything like that so you 
    //  MUST call reloadData or the like to cause it to set up its cells
    [self.gridView reloadData];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.detailDescriptionLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Detail", @"Detail");
    }
    return self;
}
							
#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - AQGridViewController

- (NSUInteger) numberOfItemsInGridView: (AQGridView *) gridView {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0u];
    return [sectionInfo numberOfObjects];
}

- (AQGridViewCell *) gridView: (AQGridView *) aGridView cellForItemAtIndex: (NSUInteger) index
{
    static NSString * CellIdentifier = @"CellIdentifier";
        
    GridImageCell * cell = (GridImageCell *)[aGridView dequeueReusableCellWithIdentifier: CellIdentifier];
    if ( cell == nil )
    {
        cell = [[GridImageCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 96, 72.0)
                                                 reuseIdentifier: CellIdentifier];
        cell.selectionGlowColor = [UIColor blueColor];
    }
    
    [self configureCell:cell atIndex:index];
    
    return ( cell );
}

- (CGSize) portraitGridCellSizeForGridView: (AQGridView *) aGridView
{
    return ( CGSizeMake(96.0, 72.0) );
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Thumbnail" inManagedObjectContext:[[self detailItem] managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:1];
    
    NSPredicate *onlyOurObject = [NSPredicate predicateWithFormat:@"parentTag == %@",[self detailItem]];
    
    [fetchRequest setPredicate:onlyOurObject];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:NO] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];

        
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[[self detailItem] managedObjectContext] sectionNameKeyPath:nil cacheName:nil] autorelease];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.gridView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    AQGridView *gridView = self.gridView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [gridView insertItemsAtIndices:[NSIndexSet indexSetWithIndex:newIndexPath.row] withAnimation:AQGridViewItemAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [gridView deleteItemsAtIndices:[NSIndexSet indexSetWithIndex:indexPath.row] withAnimation:AQGridViewItemAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[gridView cellForItemAtIndex:indexPath.row] atIndex:indexPath.row];
            break;
            
        case NSFetchedResultsChangeMove:
            [gridView deleteItemsAtIndices:[NSIndexSet indexSetWithIndex:indexPath.row] withAnimation:AQGridViewItemAnimationFade];
            [gridView insertItemsAtIndices:[NSIndexSet indexSetWithIndex:newIndexPath.row] withAnimation:AQGridViewItemAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.gridView endUpdates];
}

- (void)configureCell:(AQGridViewCell *)cell atIndex: (NSUInteger) index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [(GridImageCell *) cell setThumbnail:(Thumbnail *) object];

}

@end
