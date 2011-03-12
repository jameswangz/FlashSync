//
//  RootViewController.m
//  iPadTest
//
//  Created by James Wang on 2/25/11.
//  Copyright 2011 Freeze!. All rights reserved.
//

#import "RootViewController.h"
#import "DetailViewController.h"
#import "UITableView-WithCell.h"
#import "Constants.h"
#import "FlashSyncAppDelegate.h"
#import "NSDataUtils.h"

@implementation RootViewController

@synthesize tableView;
@synthesize detailViewController;

- (UIColor *) backgroundColor {
	return [UIColor colorWithRed:0.8 green:0.9 blue:0.9 alpha:1.0];
}

- (void) initializePanelItems {
    if ([panelItems retainCount] > 0) {
        [panelItems release];
    }
    panelItems = [[NSMutableArray alloc] init];
	
    NSMutableArray *rootItems = [[NSMutableArray alloc] init];
    [rootItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:kImported, kPath, @"已导入文件", kName, @"Bookmarks-HomeFolderIcon.png", kImage, nil]];
    [rootItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:kFlashDisk, kPath, @"U 盘文件", kName, @"Bookmarks-Drives.png", kImage, nil]];
    [panelItems addObject:rootItems];
    [rootItems release];
	
    NSMutableArray *quickLinkItems = [[NSMutableArray alloc] init];
    NSError *error = nil;
    NSString *importedFullPath = [NSDataUtils pathForFolder:kImported];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:importedFullPath error:&error];
	if (error != nil) {
        NSLog(@"Failed to read contents: %@", error);
    } else {
        for (NSString *name in contents) {
            NSString *relativePath = [NSString stringWithFormat:@"%@/%@", kImported, name];
            NSString *fullPath = [[NSDataUtils documentsDirectory] stringByAppendingPathComponent:relativePath];
            BOOL dir = [NSDataUtils isDirectory:fullPath];
            if (dir) {
                [quickLinkItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:relativePath, kPath, name, kName, @"folder.png", kImage, nil]];
            }
        }
    }
	
    [panelItems addObject:quickLinkItems];
    [quickLinkItems release];
}



#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	//self.tableView.clearsSelectionOnViewWillAppear = NO;
	//self.tableView.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    //self.tableView.backgroundColor = [self backgroundColor];
    [self initializePanelItems];
}


// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return [panelItems count];
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    NSArray *items = [panelItems objectAtIndex:section];
    return [items count];
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *items = [panelItems objectAtIndex:[indexPath section]];
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [aTableView dequeueOrInit:CellIdentifier];
    NSDictionary *dict = [items objectAtIndex:[indexPath row]];
    cell.textLabel.text = [dict objectForKey:kName];
    cell.imageView.image = [UIImage imageNamed:[dict objectForKey:kImage]];
    return cell;
}


- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"根目录";
    }
    return @"已导入快捷目录";
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FlashSyncAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.detailNavigationController popToRootViewControllerAnimated:YES];
    NSArray *items = [panelItems objectAtIndex:[indexPath section]];
    detailViewController.detailItem = [items objectAtIndex:[indexPath row]];
}



#pragma mark -
#pragma mark Memory management


- (void)viewDidUnload {
	tableView = nil;
    detailViewController = nil;
    panelItems = nil;
}


- (void)dealloc {
	[tableView release];
    [detailViewController release];
    [panelItems release];
    [super dealloc];
}

#pragma mark -
#pragma mark Custom Methods

- (void)presentWelcomeLogo:(NSString *)username {
    UILabel *welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 3, 50, 40)];
    welcomeLabel.text = [NSString stringWithFormat:@"您好, %@, 欢迎使用优盘同步工具", username];
    //welcomeLabel.backgroundColor = [self backgroundColor];
    self.tableView.tableFooterView = welcomeLabel;
    [welcomeLabel release];
}

- (void)refreshPanelItems {
    [self initializePanelItems];
    [self.tableView reloadData];
}


@end

