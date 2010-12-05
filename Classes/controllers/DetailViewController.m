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
	NSString *path = [dict objectForKey:kPath];
	self.title = [dict objectForKey:kName];
	NSError *error;
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSDataUtils pathForFolder:path] error:&error];
	
	[contentsOfCurrentFolder removeAllObjects];
	
	for (NSString *name in contents) {
		NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:[NSDataUtils pathForFolder:path name:name] error:nil];
		[contentsOfCurrentFolder addObject:[[File alloc] initWithName:name path:nil attributes:attrs]];
	}
	
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
	id type = [file.attributes objectForKey:NSFileType];
	cell.textLabel.text = file.name;
	if (type == NSFileTypeDirectory) {
		cell.imageView.image =[UIImage imageNamed:@"Dossier.png"];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else if (type == NSFileTypeRegular) {
		cell.imageView.image =[UIImage imageNamed:@"TextEdit.png"];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
	return cell;
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
//			[self performSelectorOnMainThread:@selector(showActionSheet:) 
//								   withObject:[NSArray arrayWithObjects:type, name, nil] 
//								waitUntilDone:YES];
			NSLog(@"Deleting %@", dst);
			[[NSFileManager defaultManager] removeItemAtPath:dst error:nil];
		}
		
//		[condition lock];
//		[condition wait];
//		[condition unlock];
		
		NSLog(@"Copying %@ to %@", src, dst);
		Boolean result = [[NSFileManager defaultManager] copyItemAtPath:src	toPath:dst error:&error];
		NSLog(@"Error : %@", error);
		NSLog(@"Success : %d", result);
	}
	
	[@"同步文件已完成, 请点击左侧 <已导入文件> 查看" showInDialogWithTitle:@"提示信息"]; 
}

#pragma mark -
#pragma mark UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	NSLog(@"Selected : %d", buttonIndex);
//	[condition lock];
//	[condition broadcast];
//	[condition unlock];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	[self createImportedFolderIfRequired];
	contentsOfCurrentFolder = [[NSMutableArray alloc] init];
	condition = [[NSCondition alloc] init];
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
	[condition release];
    [super dealloc];
}

#pragma mark -
#pragma mark Initialization Methods

- (void)createImportedFolderIfRequired {
	[NSDataUtils createFolderIfRequired:kImported];
}


@end
