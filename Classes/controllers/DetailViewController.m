//
//  DetailViewController.m
//  iPadTest
//
//  Created by James Wang on 2/25/11.
//  Copyright 2011 Freeze!. All rights reserved.
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
#import "NSString-UDID.h"
#import "AuthenticatonManager.h"
#import "DataEncoder.h"

@interface DetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)configureView;
- (void)createImportedFolderIfRequired;
- (void)openDirectly:(File *) file;
- (void)openWithIFile:(File *) file;
- (void)refreshRootViewController;
- (void)changeButton2Cancel;
- (void)changeTitleOfSyncButton:(NSString *)nowSyncingName;
- (void)resetSyncState;
- (void)clearSelected;
- (void)deleteSelected;
- (void)changeStateOfDeleteButton;
- (int)selectedCount;
@end


@implementation DetailViewController

@synthesize popoverController;
@synthesize detailItem;
@synthesize fullPathLabel;
@synthesize contentsTableView;
@synthesize syncButton;
@synthesize toolbar;
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
		if ([name isEqualToString:kKeyDataFileName]) {
			continue;
		}
		
		NSString *fullPath = [NSDataUtils pathForFolder:path name:name];
		NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:nil];
		File *file = [[File alloc] initWithName:name path:fullPath attributes:attrs];
		if ([file isDir]) {
			[folders addObject:file];
		} else {
			[files addObject:file];
		}
	}

	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	[folders sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[files sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	[contentsOfCurrentFolder addObjectsFromArray:folders];
	[contentsOfCurrentFolder addObjectsFromArray:files];
	[folders release];
	[files release];
}

- (void)configureView {
	NSDictionary *dict = self.detailItem;
	NSString *path = [dict objectForKey:kPath];
	self.title = [dict objectForKey:kName];
	self.fullPathLabel.text = path;
	if (path == kFlashDisk) {
		if (![AuthenticatonManager authenticate]) {
			[contentsOfCurrentFolder removeAllObjects];
			[self.contentsTableView reloadData];
			return;
		}
	}
	
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
	cell.imageView.image = file.image;
	if ([file isDir]) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.detailTextLabel.text = @"";		
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ @ %@", file.size, file.modifiedAt];		
	}
	return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate Methods

- (void) presentFilesInDir: (File *) file  {
	DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil];
	NSDictionary *dict = self.detailItem;
	NSString *path = [[dict valueForKey:kPath] stringByAppendingPathComponent:file.name];
	detailViewController.pushedFromNavigationController = YES;
	detailViewController.detailItem = [[NSDictionary alloc] initWithObjectsAndKeys:path, kPath, file.name, kName, nil];
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
}

- (void) presentContentOfFile: (File *) file  {
	activeFile = file;
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] 
								  initWithTitle:@"请选择打开方式"
								  delegate:self
								  cancelButtonTitle:@"取消"
								  destructiveButtonTitle:@"直接打开" 
								  otherButtonTitles:@"在 iFile 中打开",
								  nil];
	actionSheet.tag = kOpenWayActionSheetTag;
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (void)openDirectly:(File *)file {
	InspectorViewController *inspector = [[InspectorViewController alloc] initWithNibName:@"InspectorViewController" bundle:nil];
	inspector.url = [NSURL fileURLWithPath:file.path];
	inspector.title = file.name;
	UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:inspector];
	[self presentModalViewController:navigation animated:YES];
	[inspector release];
	[navigation release];	
}

- (void)openWithIFile:(File *)file {
	NSString *url = [[NSString stringWithFormat:@"ifile://%@", file.path] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSLog(@"url %@", url);
	BOOL canOpenURL = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]];
	if (!canOpenURL) {
		[@"无法使用 iFile 打开该文件" showInDialogWithTitle:@"错误信息"];
		return;
	}
	NSLog(@"Can open url %d", canOpenURL);
	BOOL opened = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	NSLog(@"Opened %d", opened);	
}

- (int) selectedCount {
	NSArray *selectedArray = [contentsOfCurrentFolder filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"selected == YES"]];
	return [selectedArray count];
}

- (void) changeStateOfDeleteButton {
	deleteButton.enabled = [self selectedCount] > 0;	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	File *file = [contentsOfCurrentFolder objectAtIndex:[indexPath row]];
	if (tableView.editing) {
		file.selected = YES;
		[self changeStateOfDeleteButton];
		return;
	}
	if ([file isDir]) {
		[self presentFilesInDir: file];
	} else {
		[self presentContentOfFile: file];
	}
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	File *file = [contentsOfCurrentFolder objectAtIndex:[indexPath row]];
	if (tableView.editing) {
		file.selected = NO;
		[self changeStateOfDeleteButton];
	}	
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50;
}


- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellAccessoryCheckmark;
}

#pragma mark -
#pragma mark IBAction Methods

- (IBAction)cancelSync {
	userCancelled = YES;
	[self changeTitleOfSyncButton:@"正在中止同步过程, 请稍候..."];
}

- (IBAction)syncClicked {
	if (![AuthenticatonManager authenticate]) {
		return;
	}
	UIActionSheet *actionSheet = [[UIActionSheet alloc] 
								  initWithTitle:@"同步会覆盖已导入的所有文件, 确认吗?"
								  delegate:self
								  cancelButtonTitle:@"取消"
								  destructiveButtonTitle:@"确定" 
								  otherButtonTitles:nil,
								  nil];
	actionSheet.tag = kSyncActionSheetTag;
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (void)changeButton2Cancel {
	self.syncButton.title = @"取消";
	self.syncButton.action = @selector(cancelSync);
}

- (void)changeTitleOfSyncButton:(NSString *)newTitle {
	self.syncButton.title = newTitle;
}

- (void)resetSyncState {
	self.syncButton.title = @"从 U 盘同步所有文件";
	self.syncButton.action = @selector(syncClicked);
	userCancelled = NO;
}

- (void) overwrite: (NSString *) src dst: (NSString *) dst  {
	NSError *error = nil;
	BOOL dir;
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:dst isDirectory:&dir];		
	if (fileExists) {
		[[NSFileManager defaultManager] removeItemAtPath:dst error:nil];
	}
	
	[[NSFileManager defaultManager] copyItemAtPath:src	toPath:dst error:&error];
	if (error != nil) {
		NSLog(@"Error : %@", error);
	}
}


- (void) sync: (NSString *) parentSrc to: (NSString*) parentDst  {
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:parentSrc error:nil];
	for (NSString *name in contents) {
		if (userCancelled) {
			return;
		}
		
		NSString *newTitle = [[NSString alloc] initWithFormat:@"正在同步 %@,  点击中止同步过程", name];
		[self performSelectorOnMainThread:@selector(changeTitleOfSyncButton:) withObject:newTitle waitUntilDone:YES];
		[newTitle release];
		
		NSString *src = [parentSrc stringByAppendingPathComponent:name];
		NSString *dst = [parentDst stringByAppendingPathComponent:name];
		
		BOOL dir = [NSDataUtils isDirectory:src];
		if (dir) {
			[NSDataUtils createFolderIfRequired:dst absolutePath:YES];
			[self sync:src to:dst];
		} else {
			if ([name hasSuffix:kEncodedFileSuffix]) {
				NSData *data = [[NSData alloc] initWithContentsOfFile:src];
				NSMutableData *decoded = [[NSMutableData alloc] init];
				[DataEncoder decode: data to: decoded];
				NSString *dstFileName = [dst substringToIndex:([dst length] - [kEncodedFileSuffix length])];
				[decoded writeToFile:dstFileName atomically:YES];
				[data release];
				[decoded release];
			} else {
				[self overwrite: src dst: dst];
			}
		}
	}
}

- (void) refreshRootViewController {
	FlashSyncAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	[delegate.rootViewController refreshPanelItems];
}

- (void) syncInBackground {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *src = [NSDataUtils pathForFolder:kFlashDisk];
	NSString *dst = [NSDataUtils pathForFolder:kImported];
	[self sync: src to: dst];
	
	if (userCancelled) {
		[@"同步过程被用户中止" showInDialogWithTitle:@"提示信息"];	
	} else {
		[@"同步文件已完成, 请点击左侧 [已导入文件] 查看" showInDialogWithTitle:@"提示信息"];	
	}
	
	[self configureView];
	[self refreshRootViewController];
	[pool release];
	
	[self performSelectorOnMainThread:@selector(resetSyncState) withObject:nil waitUntilDone:YES];
}


- (void)syncAll {
	[self changeButton2Cancel];
	[self performSelectorInBackground:@selector(syncInBackground) withObject:nil];
}

- (void)clearSelected {
	for (File *file in contentsOfCurrentFolder) {
		file.selected = NO;
	}
}

- (void) addDeleteButton {
	NSMutableArray *items = [self.toolbar.items mutableCopy];
	deleteButton = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"删除选中文件"]
													style:UIBarButtonItemStyleBordered
												   target:self 
												   action:@selector(deleteClicked)];
	deleteButton.enabled = NO;
	[items insertObject:deleteButton atIndex:2];
	[deleteButton release];
	[self.toolbar setItems:items animated:YES];
	[items release];	
}

- (void) removeDeleteButton {
	NSMutableArray *items = [self.toolbar.items mutableCopy];
	[items removeObjectAtIndex:2];
	[self.toolbar setItems:items animated:YES];
	[items release];
}

- (IBAction)toggleEdit {
	[self.contentsTableView setEditing:!self.contentsTableView.editing animated:YES];
	if (self.contentsTableView.editing) {
		self.navigationItem.rightBarButtonItem.title = @"完成";
		self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;
		[self clearSelected];
		[self addDeleteButton];
	} else {
		self.navigationItem.rightBarButtonItem.title = @"编辑";
		self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStylePlain;
		[self removeDeleteButton];
	}
}

- (IBAction)deleteClicked {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] 
								  initWithTitle:@""
								  delegate:self
								  cancelButtonTitle:@"取消"
								  destructiveButtonTitle:[NSString stringWithFormat:@"删除 %d 个文件", [self selectedCount]]
								  otherButtonTitles:nil,
								  nil];
	actionSheet.tag = kDeleteActionSheetTag;
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[actionSheet showInView:self.view];
	[actionSheet release];
}

#pragma mark -
#pragma mark UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == kSyncActionSheetTag) {
		if (buttonIndex == 0) {
			[self syncAll];
		}		
	}
	else if (actionSheet.tag == kOpenWayActionSheetTag) {
		if (buttonIndex == 0) {
			[self openDirectly:activeFile];
		} else if (buttonIndex == 1) {
			[self openWithIFile:activeFile];
		}
	}
	else if (actionSheet.tag == kDeleteActionSheetTag) {
		if (buttonIndex == 0) {
			[self deleteSelected];
		}
	}
}

#pragma mark -
#pragma mark View lifecycle

- (void) addEditButton {
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑" 
																   style:UIBarButtonItemStyleBordered 
																  target:self 
																  action:@selector(toggleEdit)];
	self.navigationItem.rightBarButtonItem = editButton;
	[editButton release];

}
- (void)viewDidLoad {
	[self createImportedFolderIfRequired];
	contentsOfCurrentFolder = [[NSMutableArray alloc] init];
	if ([self.detailItem isKindOfClass:[NSDictionary class]] == NO) {
		self.detailItem = [[NSDictionary alloc] initWithObjectsAndKeys:kImported, kPath, @"已导入文件", kName, nil];
	}
	if (pushedFromNavigationController) {
		[self configureView];
	}
	[self addEditButton];
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    self.popoverController = nil;
	self.fullPathLabel = nil;
	self.contentsTableView = nil;
	self.syncButton = nil;
	deleteButton = nil;
	self.toolbar = nil;
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
	[toolbar release];
	[super dealloc];
}

#pragma mark -
#pragma mark Initialization Methods

- (void)createImportedFolderIfRequired {
	[NSDataUtils createFolderIfRequired:kImported];
}


#pragma mark -
#pragma mark Delete File Methods

- (void)deleteSelected {	
	NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
	NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
	
	for (int i = 0; i < [contentsOfCurrentFolder count]; i++) {
		File *file = [contentsOfCurrentFolder objectAtIndex:i];
		if (file.selected) {
			NSLog(@"Deleting %@", file.path);
			NSError *error = nil;
			[[NSFileManager defaultManager] removeItemAtPath:file.path error:&error];
			if (error != nil) {
				[error showInDialog];
				return;
			}
			
			[self refreshRootViewController];
			
			[indexes addIndex:i];
			[indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];		
		}
	}
	
	[contentsOfCurrentFolder removeObjectsAtIndexes:indexes];
	[indexes release];
	
	[self.contentsTableView beginUpdates];
	[self.contentsTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
	[self.contentsTableView endUpdates];
	[indexPaths release];
	
	[self changeStateOfDeleteButton];
	[self refreshRootViewController];
}

@end
