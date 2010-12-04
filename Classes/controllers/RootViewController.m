//
//  RootViewController.m
//  FlashSync
//
//  Created by James Wang on 11/28/10.
//  Copyright DerbySoft 2010. All rights reserved.
//

#import "RootViewController.h"
#import "DetailViewController.h"
#import "UITableView-WithCell.h"
#import "Constants.h"

@implementation RootViewController

@synthesize detailViewController;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
	panelItems = [[NSArray alloc] initWithObjects:@"已导入文件", @"U 盘文件", nil];
}


// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return [panelItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueOrInit:CellIdentifier];
    cell.textLabel.text = (NSString *) [panelItems objectAtIndex:[indexPath row]];
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString * path = nil;
	int row = [indexPath row];
	if (row == 0) {
		path = kImported;
	} else {
		path = kFlashDisk;
	}
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:path forKey:@"path"];
	[dict setObject:[panelItems objectAtIndex:[indexPath row]] forKey:@"name"];
    detailViewController.detailItem = dict;
}


#pragma mark -
#pragma mark Memory management


- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [detailViewController release];
	[panelItems release];
    [super dealloc];
}


@end

