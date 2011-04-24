//
//  DetailViewController.h
//  FlashSync
//
//  Created by James Wang on 11/28/10.
//  Copyright DerbySoft 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "File.h"
#import "FileSynchronizer.h"

#define kSyncActionSheetTag		1
#define kOpenWayActionSheetTag	2
#define kDeleteActionSheetTag	3
#define kFavoriteActionSheetTag	4

#define kDeleteButtonTag		99
#define kFavoriteButtonTag		100

#define kSkipButtonIndex		3

@interface DetailViewController : UIViewController<UIPopoverControllerDelegate, UISplitViewControllerDelegate, 
	UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UINavigationControllerDelegate> {
    
    UIPopoverController *popoverController;    
    id detailItem;
	BOOL pushedFromNavigationController;
	NSMutableArray *contentsOfCurrentFolder;
	UITableView *contentsTableView;
	UIBarButtonItem *syncStatusButton;
	UIBarButtonItem *syncButton;
	UIBarButtonItem *deleteButton;
	UIBarButtonItem *favoriteButton;
	UIBarButtonItem *skipButton;
		
	File *activeFile;
	BOOL userCancelled;
	FileSynchronizer *fileSynchronizer;
	BOOL selectedAll;
}

@property (nonatomic, retain) id detailItem;
@property (nonatomic, retain) IBOutlet UITableView *contentsTableView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *syncStatusButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *syncButton;
@property (nonatomic) BOOL pushedFromNavigationController;

- (IBAction)syncClicked;
- (IBAction)cancelSync;
- (IBAction)toggleEdit;
- (IBAction)deleteClicked;

@end
