//
//  DetailViewController.m
//  FlashSync
//
//  Created by James Wang on 11/28/10.
//  Copyright DerbySoft 2010. All rights reserved.
//

#import "DetailViewController.h"
#import "RootViewController.h"
#import "NSObject-Dialog.h"
#import "UITableView-WithCell.h"
#import "NSDataUtils.h"
#import "Constants.h"
#import "File.h"

@interface DetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)configureView;
- (void)createImportedFolderIfRequired;
@end


@implementation DetailViewController

@synthesize popoverController;
@synthesize detailItem;
@synthesize fullPathLabel;
@synthesize contentsTableView;

#pragma mark -
#pragma mark Managing the detail item

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */
- (void)setDetailItem:(id)newDetailItem {
    if (detailItem != newDetailItem) {
        [detailItem release];
        detailItem = [newDetailItem retain];
		// Update the view.
        [self configureView];
    }

    if (popoverController != nil) {
        [popoverController dismissPopoverAnimated:YES];
    }        
}


- (void)configureView {
	NSDictionary *dict = self.detailItem;
	NSString *path = [dict objectForKey:@"path"];
	self.title = [dict objectForKey:@"name"];
	NSError *error;
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSDataUtils pathForFolder:path] error:&error];
	NSLog(@"contents : %@", contents);

	[contentsOfCurrentFolder removeAllObjects];
	
	for (NSString *name in contents) {
		NSLog(@"content : %@", name);
		NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:[NSDataUtils pathForFolder:path name:name] error:nil];
		NSLog(@"attrs : %@", attrs);
		[contentsOfCurrentFolder addObject:[[File alloc] initWithName:name path:nil attributes:attrs]];
	}
	
	NSLog(@"contentsOfCurrentFolder : %@", contentsOfCurrentFolder);
	
	[self.contentsTableView reloadData];
}


#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
	self.popoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    self.popoverController = nil;
}


#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark UITableView DataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return [contentsOfCurrentFolder count];
}

- (UITableViewCell *) tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [table dequeueOrInit:@"Cell"];
	File *file = [contentsOfCurrentFolder objectAtIndex:[indexPath row]];
	id type = [file.attributes objectForKey:NSFileType];
	if (type == NSFileTypeDirectory) {
		NSLog(@"dir");
	} else if (type == NSFileTypeRegular) {
		NSLog(@"file");
	}	
	cell.textLabel.text = file.name;
	return cell;
}

#pragma mark -
#pragma mark IBAction Methods

- (IBAction)syncAll {
	[@"Syncing" showInDialog];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	[self createImportedFolderIfRequired];
	contentsOfCurrentFolder = [[NSMutableArray alloc] init];
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.popoverController = nil;
	self.fullPathLabel = nil;
	self.contentsTableView = nil;
}


#pragma mark -
#pragma mark Memory management


- (void)dealloc {
    [popoverController release];
    [detailItem release];
	[fullPathLabel release];
	[contentsTableView release];
	[contentsOfCurrentFolder release];
    [super dealloc];
}

#pragma mark -
#pragma mark Initialization Methods

- (void)createImportedFolderIfRequired {
	[NSDataUtils createFolderIfRequired:kImported];
}


@end
