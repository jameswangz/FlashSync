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
#import "FlashSyncAppDelegate.h"
#import "InspectorViewController.h"

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
@synthesize syncButton;
@synthesize pushedFromNavigationController;

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


- (void) fillContentsOfCurrentFolder: (NSString *) path  {
	NSError *error;
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSDataUtils pathForFolder:path] error:&error];
	
	[contentsOfCurrentFolder removeAllObjects];
	
	NSMutableArray *folders = [[NSMutableArray alloc] init];
	NSMutableArray  *files = [[NSMutableArray alloc] init];
	
	for (NSString *name in contents) {
		NSString *fullPath = [NSDataUtils pathForFolder:path name:name];
		NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:nil];
		File *file = [[File alloc] initWithName:name path:fullPath attributes:attrs];
		if ([file isDir]) {
			[folders addObject:file];
		} else {
			[files addObject:file];
		}
	}

	[contentsOfCurrentFolder addObjectsFromArray:folders];
	[contentsOfCurrentFolder addObjectsFromArray:files];
	[folders release];
	[files release];
}

- (void)configureView {
	NSDictionary *dict = self.detailItem;
	NSString *path = [dict objectForKey:kPath];
	NSLog(@"name : %@", dict);
	self.title = [dict objectForKey:kName];
	self.fullPathLabel.text = path;
	[self fillContentsOfCurrentFolder: path];
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
	UITableViewCell *cell = [table dequeueOrInit:@"Cell" withStyle:UITableViewCellStyleSubtitle];
	File *file = [contentsOfCurrentFolder objectAtIndex:[indexPath row]];
	cell.textLabel.text = file.name;
	if ([file isDir]) {
		cell.imageView.image =[UIImage imageNamed:@"Dossier.png"];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else {
		cell.imageView.image =[UIImage imageNamed:@"TextEdit.png"];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
	return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (void) presentFilesInDir: (File *) file  {
	DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil];
	NSDictionary *dict = self.detailItem;
	NSString *path = [[dict valueForKey:kPath] stringByAppendingPathComponent:file.name];
	NSLog(@"%@", path);
	detailViewController.pushedFromNavigationController = YES;
	detailViewController.detailItem = [[NSDictionary alloc] initWithObjectsAndKeys:path, kPath, file.name, kName, nil];
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
}

- (void) presentContentOfFile: (File *) file  {
//		NSString *url = [NSString stringWithFormat:@"ifile://%@", file.path];
//		NSLog(@"url %@", url);
//		BOOL canOpenURL = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]];
//		NSLog(@"Can open url %d", canOpenURL);
//		BOOL opened = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
//		NSLog(@"Opened %d", opened);

	InspectorViewController *inspector = [[InspectorViewController alloc] initWithNibName:@"InspectorViewController" bundle:nil];
	inspector.url = [NSURL fileURLWithPath:file.path];
	inspector.title = file.name;
	UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:inspector];
	[self presentModalViewController:navigation animated:YES];
	[inspector release];
	[navigation release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	File *file = [contentsOfCurrentFolder objectAtIndex:[indexPath row]];
	if ([file isDir]) {
		[self presentFilesInDir: file];
	} else {
		[self presentContentOfFile: file];
	}
}

#pragma mark -
#pragma mark IBAction Methods

- (void) showActionSheet: (NSArray *) params {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] 
								  initWithTitle:[NSString stringWithFormat:@"%@ %@ 已存在", [params objectAtIndex:0], [params objectAtIndex:1]]
								  delegate:self
								  cancelButtonTitle:@"跳过"
								  destructiveButtonTitle:@"覆盖" 
								  otherButtonTitles:@"全部覆盖",
								  nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[actionSheet showInView:self.view];
	[actionSheet release];

}
- (IBAction)syncAll {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] 
								  initWithTitle:@"同步会覆盖已导入的所有文件, 确认吗?"
								  delegate:self
								  cancelButtonTitle:@"取消"
								  destructiveButtonTitle:@"确定" 
								  otherButtonTitles:nil,
								  nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (void)disableSyncButton {
	self.syncButton.title = @"同步中, 请稍候...";
	self.syncButton.enabled = NO;
}

- (void)enableSyncButton {
	self.syncButton.title = @"从 U 盘同步所有文件";
	self.syncButton.enabled = YES;
}

- (void) syncInBackground {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSDataUtils pathForFolder:kFlashDisk] error:nil];
	
	for (NSString *name in contents) {
		NSError *error = nil;
		NSString *src = [NSDataUtils pathForFolder:[NSString stringWithFormat:@"%@/%@", kFlashDisk, name]];
		NSString *dst = [NSDataUtils pathForFolder:[NSString stringWithFormat:@"%@/%@", kImported, name]];
		
		BOOL dir;
		NSString *type = @"文件";
		BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:dst isDirectory:&dir];
		if (dir) {
			type = @"目录";
		}
		
		if (fileExists) {
			NSLog(@"Deleting %@", dst);
			[[NSFileManager defaultManager] removeItemAtPath:dst error:nil];
		}
		
		NSLog(@"Copying %@ to %@", src, dst);
		Boolean result = [[NSFileManager defaultManager] copyItemAtPath:src	toPath:dst error:&error];
		NSLog(@"Error : %@", error);
		NSLog(@"Success : %d", result);
	}
	
	
	[@"同步文件已完成, 请点击左侧 [已导入文件] 查看" showInDialogWithTitle:@"提示信息"];	
	[self performSelectorOnMainThread:@selector(enableSyncButton) withObject:nil waitUntilDone:YES];
	
	[pool release];
}


- (void)actualSync {
	[self disableSyncButton];
	[self performSelectorInBackground:@selector(syncInBackground) withObject:nil];
}

#pragma mark -
#pragma mark UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	NSLog(@"Selected : %d", buttonIndex);	
	if (buttonIndex == 0) {
		[self performSelectorInBackground:@selector(actualSync) withObject:nil];
	}
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	[self createImportedFolderIfRequired];
	contentsOfCurrentFolder = [[NSMutableArray alloc] init];
	if ([self.detailItem isKindOfClass:[NSDictionary class]] == NO) {
		self.detailItem = [[NSDictionary alloc] initWithObjectsAndKeys:kImported, kPath, @"已导入文件", kName, nil];
	}
	if (pushedFromNavigationController) {
		[self configureView];
	}
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    self.popoverController = nil;
	self.fullPathLabel = nil;
	self.contentsTableView = nil;
	self.syncButton = nil;
}


#pragma mark -
#pragma mark Memory management


- (void)dealloc {
    [popoverController release];
    [detailItem release];
	[fullPathLabel release];
	[contentsTableView release];
	[contentsOfCurrentFolder release];
	[syncButton release];
	[super dealloc];
}

#pragma mark -
#pragma mark Initialization Methods

- (void)createImportedFolderIfRequired {
	[NSDataUtils createFolderIfRequired:kImported];
}


@end
