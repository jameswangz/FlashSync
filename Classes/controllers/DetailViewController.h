//
//  DetailViewController.h
//  FlashSync
//
//  Created by James Wang on 11/28/10.
//  Copyright DerbySoft 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "File.h"

#define kSyncActionSheetTag		1
#define kOpenWayActionSheetTag	2
#define kDeleteActionSheetTag	3


@interface DetailViewController : UIViewController<UIPopoverControllerDelegate, UISplitViewControllerDelegate, 
	UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
    
    UIPopoverController *popoverController;    
    id detailItem;
	BOOL pushedFromNavigationController;
	NSMutableArray *contentsOfCurrentFolder;
	UILabel *fullPathLabel;
	UITableView *contentsTableView;
	UIBarButtonItem *syncButton;
	UIBarButtonItem *deleteButton;
	UIToolbar *toolbar;
		
	File *activeFile;
	BOOL userCancelled;
}


@property (nonatomic, retain) id detailItem;
@property (nonatomic, retain) IBOutlet UILabel *fullPathLabel;
@property (nonatomic, retain) IBOutlet UITableView *contentsTableView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *syncButton;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic) BOOL pushedFromNavigationController;

- (IBAction)syncClicked;
- (IBAction)cancelSync;
- (IBAction)toggleEdit;
- (IBAction)deleteClicked;

@end
