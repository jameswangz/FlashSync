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


@interface DetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)configureView;
- (void)createFoldersIfRequired;
- (void)openDirectly:(File *) file;
- (void)openWithIFile:(File *) file;
- (void)refreshRootViewController;
- (void)changeTitleOfSyncStatusButton:(NSString *)nowSyncingName;
- (void)changeSyncState2Cancel;
- (void)resetSyncState;
- (void)clearSelected;
- (void)addOperationButtons;
- (void)removeOperationButtons;
- (void)deleteSelected;
- (void)changeStateOfOperationButtons;
- (NSArray *)selectedFiles;
- (int)selectedCount;
- (void)addSkipButton;
- (void)removeSkipButton;
- (void)skipCurrentFile;
- (void)setGlogalToolbarItems:(NSArray *) items;
- (BOOL)inFavoriteFolder;
- (NSString *)currentPath;
- (FlashSyncAppDelegate *)appDelegate;
- (BOOL)globalWorking;
- (void)globalWorkStarted;
- (void)globalWorkFinished;
- (void)addFavorites;
- (void)addFavoritesInBackground:(NSArray *) files;
- (void)configureTableView;
- (void)setStatusWhileWorkStarted;
- (void)setStatusWhileWorkFinished;
- (DetailViewController *)topController;
@end

@implementation DetailViewController

@synthesize popoverController;
@synthesize detailItem;
@synthesize contentsTableView;
@synthesize syncStatusButton;
@synthesize syncButton;
@synthesize pushedFromNavigationController;

#pragma mark -
#pragma mark Managing the detail item

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */
- (void)setDetailItem:(id)newDetailItem {
    if (detailItem != newDetailItem) {
		NSLog(@"detail item %@", newDetailItem);
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
	if (path == kFlashDisk) {
		if (![AuthenticatonManager authenticate]) {
			[contentsOfCurrentFolder removeAllObjects];
			[self.contentsTableView reloadData];
			return;
		}
	}
	
	[self fillContentsOfCurrentFolder: path];
	
	DetailViewController *topController = [self topController];
	[topController.contentsTableView reloadData];
	topController.contentsTableView.editing = NO;
	[topController configureTableView];
}



#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
//	barButtonItem.title = @"导航";
//    NSMutableArray *items = [[toolbar items] mutableCopy];
//    [items insertObject:barButtonItem atIndex:0];
//    [toolbar setItems:items animated:YES];
//    [items release];
    self.popoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
//	NSMutableArray *items = [[toolbar items] mutableCopy];
//    if ([items count] > 3) {
//		[items removeObjectAtIndex:0];
//		[toolbar setItems:items animated:YES];
//	}
//	[items release];
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
		if (file.modifiedAt != nil) {
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ @ %@", file.size, file.modifiedAt];		
		}
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
	[self setGlogalToolbarItems:self.navigationController.topViewController.toolbarItems];
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
}

- (void) presentContentOfFile: (File *) file  {
	activeFile = file;
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] 
								  initWithTitle:@"请选择打开方式"
								  delegate:self
								  cancelButtonTitle:nil
								  destructiveButtonTitle:@"直接打开" 
								  otherButtonTitles:@"在 iFile 中打开", @"取消",
								  nil];
	actionSheet.tag = kOpenWayActionSheetTag;
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[actionSheet showInView:self.navigationController.view];
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

- (NSArray *)selectedFiles {
	return [contentsOfCurrentFolder filteredArrayUsingPredicate:
			[NSPredicate predicateWithFormat:@"selected == YES"]];
}

- (int) selectedCount {
	return [[self selectedFiles] count];
}

- (void) changeStateOfOperationButtons {
	BOOL shouldEnable = self.contentsTableView.editing && ![self globalWorking] && [self selectedCount] > 0;
	deleteButton.enabled = shouldEnable;
	favoriteButton.enabled = shouldEnable;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	File *file = [contentsOfCurrentFolder objectAtIndex:[indexPath row]];
	if (tableView.editing) {
		file.selected = YES;
		[self changeStateOfOperationButtons];
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
		[self changeStateOfOperationButtons];
	}	
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50;
}


- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellAccessoryCheckmark;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSDictionary *dict = self.detailItem;
	return [dict objectForKey:kPath];
}

#pragma mark -
#pragma mark IBAction Methods

- (IBAction)cancelSync {
	[self changeTitleOfSyncStatusButton:@"正在中止同步过程..."];
	userCancelled = YES;
	fileSynchronizer.skip = YES;
}

- (void)skipCurrentFile {
	NSString *title = [[NSString alloc] initWithFormat:@"正在跳过 %@...", [fileSynchronizer syncingFileName]];
	[self changeTitleOfSyncStatusButton:title];
	[title release];
	fileSynchronizer.skip = YES;	
}

- (IBAction)syncClicked {
	if (![AuthenticatonManager authenticate]) {
		return;
	}
	UIActionSheet *actionSheet = [[UIActionSheet alloc] 
								  initWithTitle:@"同步会覆盖已导入的所有文件, 确认吗?"
								  delegate:self
								  cancelButtonTitle:nil
								  destructiveButtonTitle:@"确定" 
								  otherButtonTitles:@"取消",
								  nil];
	actionSheet.tag = kSyncActionSheetTag;
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[actionSheet showInView:self.navigationController.view];
	[actionSheet release];
}

- (void)changeTitleOfSyncStatusButton:(NSString *)newTitle {
	self.syncStatusButton.title = newTitle;
}


- (void)changeSyncState2Cancel {
	NSString *newTitle = [[NSString alloc] initWithFormat:@"中止%@过程", [self appDelegate].workName];
	self.syncButton.title = newTitle;
	[newTitle release];
	self.syncButton.action = @selector(cancelSync);
}

- (void)resetSyncState {
	self.syncButton.title = @"同步所有文件";
	self.syncButton.action = @selector(syncClicked);
	userCancelled = NO;
}


- (void) syncSingle: (NSString *) src to: (NSString *) dst  {
	NSLog(@"syncsingle %@ to %@", src, dst);
	fileSynchronizer.skip = userCancelled;
	NSString *name = [src lastPathComponent];
	
	NSString *newTitle = [[NSString alloc] initWithFormat:@"正在%@ %@...", [self appDelegate].workName, name];
	[self performSelectorOnMainThread:@selector(changeTitleOfSyncStatusButton:) withObject:newTitle waitUntilDone:YES];
	[newTitle release];
	
	if ([name hasSuffix:kEncodedFileSuffix]) {
		NSString *dstFileName = [dst substringToIndex:([dst length] - [kEncodedFileSuffix length])];
		[fileSynchronizer syncFrom:src to:dstFileName decode:YES];
	} else {
		[fileSynchronizer syncFrom:src to:dst decode:NO];
	}	
}

- (void) sync: (NSString *) parentSrc to: (NSString*) parentDst  {
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:parentSrc error:nil];
	for (NSString *name in contents) {
		if (userCancelled) {
			return;
		}
		
		NSString *src = [parentSrc stringByAppendingPathComponent:name];
		NSString *dst = [parentDst stringByAppendingPathComponent:name];
	
		BOOL dir = [NSDataUtils isDirectory:src];
		if (dir) {
			[NSDataUtils createFolderIfRequired:dst absolutePath:YES];
			[self sync:src to:dst];
		} else {
			[self syncSingle:src to:dst];
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

	[self setStatusWhileWorkFinished];
}

- (void)syncAll {
	[self appDelegate].workName = @"同步";
	[self setStatusWhileWorkStarted];
	[self performSelectorInBackground:@selector(syncInBackground) withObject:nil];
}

- (void)setStatusWhileWorkStarted {
	[self globalWorkStarted];
	[self changeSyncState2Cancel];
	[self addSkipButton];
	[self changeStateOfOperationButtons];
}

- (void) setStatusWhileWorkFinished {
	[self performSelectorOnMainThread:@selector(globalWorkFinished) withObject:nil waitUntilDone:YES];
	[self performSelectorOnMainThread:@selector(resetSyncState) withObject:nil waitUntilDone:YES];
	[self performSelectorOnMainThread:@selector(changeTitleOfSyncStatusButton:) withObject:@"" waitUntilDone:YES]; 
	[self performSelectorOnMainThread:@selector(removeSkipButton) withObject:nil waitUntilDone:YES];
	[self performSelectorOnMainThread:@selector(changeStateOfOperationButtons) withObject:nil waitUntilDone:YES];	
}

- (void)clearSelected {
	for (File *file in contentsOfCurrentFolder) {
		file.selected = NO;
	}
}

- (void) addOperationButtons {
	UIViewController *topController = self.navigationController.topViewController;
	NSMutableArray *items = [topController.toolbarItems mutableCopy];
	
	deleteButton = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"删除"]
													style:UIBarButtonItemStyleBordered
												   target:self 
												   action:@selector(deleteClicked)];
	deleteButton.enabled = NO;
	deleteButton.tag = kDeleteButtonTag;
	[items addObject:deleteButton];
	
	if (![self inFavoriteFolder]) {
		favoriteButton = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"收藏"]
														  style:UIBarButtonItemStyleBordered
														 target:self 
														 action:@selector(favoriteClicked)];
		favoriteButton.enabled = NO;
		favoriteButton.tag = kFavoriteButtonTag;
		[items addObject:favoriteButton];
	}
	
	[topController setToolbarItems:items animated:YES];
	[items release];	
}

- (void) removeOperationButtons {
	UIViewController *topController = self.navigationController.topViewController;
	NSMutableArray *items = [topController.toolbarItems mutableCopy];
	NSPredicate *removePredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
		UIBarButtonItem *item = (UIBarButtonItem *) evaluatedObject;
		return item.tag != kDeleteButtonTag && item.tag != kFavoriteButtonTag;
	}];
	[items filterUsingPredicate:removePredicate];
	[topController setToolbarItems:items animated:YES];
	[items release];
}

- (void)setGlogalToolbarItems:(NSArray *)allItems {
	//don't pass the delete button
	NSMutableArray *items = [[NSMutableArray alloc] init];	
	for (UIBarButtonItem *item in allItems) {
		if (item.tag != kDeleteButtonTag && item.tag != kFavoriteButtonTag) {
			[items addObject:item];
		}
	}
	
	FlashSyncAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	delegate.detailViewToolbarItems = items;
	[items release];
}

- (void) addSkipButton {
	UIViewController *topController = self.navigationController.topViewController;
	NSMutableArray *items = [topController.toolbarItems mutableCopy];
	skipButton = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"跳过当前文件"]
																   style:UIBarButtonItemStyleBordered
																  target:self 
																  action:@selector(skipCurrentFile)];
	[items insertObject:skipButton atIndex:kSkipButtonIndex];
	[skipButton release];
	[topController setToolbarItems:items animated:YES];
	[self setGlogalToolbarItems:items];
	[items release];	
}

- (void) removeSkipButton {
	UIViewController *topController = self.navigationController.topViewController;
	NSMutableArray *items = [topController.toolbarItems mutableCopy];
	[items removeObjectAtIndex:kSkipButtonIndex];
	[topController setToolbarItems:items animated:YES];
	[self setGlogalToolbarItems:items];
	[items release];
}


- (IBAction)toggleEdit {
	DetailViewController *topController = [self topController];
	[topController.contentsTableView setEditing:!self.contentsTableView.editing animated:YES];
	[topController configureTableView];	
}

- (void)configureTableView {
	DetailViewController *topController = [self topController];
	
	if (topController.contentsTableView.editing) {
		topController.navigationItem.rightBarButtonItem.title = @"完成";
		topController.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;
		[topController clearSelected];
		[topController addOperationButtons];
	} else {
		topController.navigationItem.rightBarButtonItem.title = @"编辑";
		topController.navigationItem.rightBarButtonItem.style = UIBarButtonItemStylePlain;
		[topController removeOperationButtons];
	}
}


- (IBAction)deleteClicked {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] 
								  initWithTitle:@""
								  delegate:self
								  cancelButtonTitle:nil
								  destructiveButtonTitle:[NSString stringWithFormat:@"删除 %d 个文件", [self selectedCount]]
								  otherButtonTitles:@"取消",
								  nil];
	actionSheet.tag = kDeleteActionSheetTag;
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[actionSheet showInView:self.navigationController.view];
	[actionSheet release];
}

- (IBAction)favoriteClicked {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] 
								  initWithTitle:@""
								  delegate:self
								  cancelButtonTitle:nil
								  destructiveButtonTitle:[NSString stringWithFormat:@"收藏 %d 个文件", [self selectedCount]]
								  otherButtonTitles:@"取消",
								  nil];
	actionSheet.tag = kFavoriteActionSheetTag;
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[actionSheet showInView:self.navigationController.view];
	[actionSheet release];
}

#pragma mark -
#pragma mark UINavigationControllerDelegate Methods

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	FlashSyncAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	if ([delegate.detailViewToolbarItems count] > 0) {
		viewController.toolbarItems = delegate.detailViewToolbarItems;	
	}
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
	else if (actionSheet.tag = kFavoriteActionSheetTag) {
		if (buttonIndex == 0) {
			[self addFavorites];
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
	[self createFoldersIfRequired];
	contentsOfCurrentFolder = [[NSMutableArray alloc] init];
	if ([self.detailItem isKindOfClass:[NSDictionary class]] == NO) {
		self.detailItem = [[NSDictionary alloc] initWithObjectsAndKeys:kImported, kPath, @"已导入文件", kName, nil];
	}
	if (pushedFromNavigationController) {
		[self configureView];
	}
	[self addEditButton];
	fileSynchronizer = [[FileSynchronizer alloc] init];
}

- (void)viewDidUnload {
    self.popoverController = nil;
	self.contentsTableView = nil;
	self.syncStatusButton = nil;
	self.syncButton = nil;
	fileSynchronizer = nil;
}


#pragma mark -
#pragma mark Memory management


- (void)dealloc {
    [popoverController release];
	[detailItem release];
	[contentsTableView release];
	[contentsOfCurrentFolder release];
	[syncStatusButton release];
	[syncButton release];
	[fileSynchronizer release];
	[super dealloc];
}

#pragma mark -
#pragma mark Initialization Methods

- (void)createFoldersIfRequired {
	[NSDataUtils createFolderIfRequired:kImported];
	[NSDataUtils createFolderIfRequired:kFavorite];
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
	
	[self changeStateOfOperationButtons];
	[self refreshRootViewController];
}

#pragma mark -
#pragma mark Add Favorites methods

- (void)addFavorites {
	[self appDelegate].workName = @"收藏";
	[self setStatusWhileWorkStarted];
	NSArray *selectedFiles = [self selectedFiles];
	[self performSelectorInBackground:@selector(addFavoritesInBackground:) withObject:selectedFiles];
}

- (void) addFavoritesInBackground:(NSArray *)files {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	for (File * file in files) {
		NSString *src = file.path;
		NSString *dst = [[NSDataUtils pathForFolder:kFavorite] stringByAppendingPathComponent:[src lastPathComponent]];
		
		NSLog(@"favorite dst %@", dst);
		
		BOOL dir = [NSDataUtils isDirectory:src];
		if (dir) {
			[NSDataUtils createFolderIfRequired:dst absolutePath:YES];
			[self sync: src to: dst];		
		} else {
			[self syncSingle:src to:dst];
		}
	}
	
	if (userCancelled) {
		[@"收藏过程被用户中止" showInDialogWithTitle:@"提示信息"];
	} else {
		[@"收藏文件已完成, 请点击左侧 [收藏夹] 查看" showInDialogWithTitle:@"提示信息"];
	}
	
	[self configureView];
	[self refreshRootViewController];
	[pool release];	
	
	[self setStatusWhileWorkFinished];
}


#pragma mark -
#pragma mark helper methods

- (NSString *)currentPath {
	NSDictionary *dict = self.detailItem;
	return [dict objectForKey:kPath];
}

- (BOOL)inFavoriteFolder {
	NSString *path = [self currentPath];
	NSLog(@"path %@", path);
	return [path hasPrefix:kFavorite];
}

- (FlashSyncAppDelegate *)appDelegate {
	return [[UIApplication sharedApplication] delegate];
}

- (BOOL)globalWorking {
	return [self appDelegate].working;
}

- (void)globalWorkStarted {
	[self appDelegate].working = YES;
}

- (void)globalWorkFinished {
	[self appDelegate].working = NO;
}

- (DetailViewController *)topController {
	DetailViewController *topController = (DetailViewController *) self.navigationController.topViewController;
	return topController;
}

@end
