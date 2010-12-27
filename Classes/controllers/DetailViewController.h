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


@interface DetailViewController : UIViewController<UIPopoverControllerDelegate, UISplitViewControllerDelegate, 
	UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
    
    UIPopoverController *popoverController;    
    id detailItem;
	BOOL pushedFromNavigationController;
	NSMutableArray *contentsOfCurrentFolder;
	UILabel *fullPathLabel;
	UITableView *contentsTableView;
	UIBarItem *syncButton;
	
	File *activeFile;
}


@property (nonatomic, retain) id detailItem;
@property (nonatomic, retain) IBOutlet UILabel *fullPathLabel;
@property (nonatomic, retain) IBOutlet UITableView *contentsTableView;
@property (nonatomic, retain) IBOutlet UIBarItem *syncButton;
@property (nonatomic) BOOL pushedFromNavigationController;

- (IBAction)syncAll;
- (IBAction)toggleEdit;

@end
