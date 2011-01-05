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
#import "FlashSyncAppDelegate.h"

@implementation RootViewController

@synthesize detailViewController;


#pragma mark -
#pragma mark View lifecycle


- (UIColor *) backgroundColor {
  return [UIColor colorWithRed:0.8 green:0.9 blue:0.9 alpha:1.0];
}

- (void)viewDidLoad {
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
	self.tableView.backgroundColor = [self backgroundColor];
	panelItems = [[NSMutableArray alloc] init];
	[panelItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:kImported, kPath, @"已导入文件", kName, @"HDD.png", kImage, nil]];
	[panelItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:kFlashDisk, kPath, @"U 盘文件", kName, @"HDD USB.png", kImage, nil]];
}


// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationLandscapeRight;
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
	NSDictionary *dict = [panelItems objectAtIndex:[indexPath row]];
    cell.textLabel.text = [dict objectForKey:kName];
	cell.imageView.image = [UIImage imageNamed:[dict objectForKey:kImage]];
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	FlashSyncAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	[delegate.detailNavigationController popToRootViewControllerAnimated:YES];
	detailViewController.detailItem = [panelItems objectAtIndex:[indexPath row]];
}


#pragma mark -
#pragma mark Memory management


- (void)viewDidUnload {
	detailViewController = nil;
	panelItems = nil;
}


- (void)dealloc {
    [detailViewController release];
	[panelItems release];
    [super dealloc];
}

#pragma mark -
#pragma mark Custom Methods

- (void)presentWelcomeLogo:(NSString *)username {
	UILabel *welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 3, 50, 40)];
	welcomeLabel.text = [NSString stringWithFormat:@"您好, %@, 欢迎使用优盘同步工具", username];
	welcomeLabel.backgroundColor = [self backgroundColor];
	self.tableView.tableFooterView = welcomeLabel;
	[welcomeLabel release];
}


@end

