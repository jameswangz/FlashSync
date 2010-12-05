//
//  DetailViewController.h
//  FlashSync
//
//  Created by James Wang on 11/28/10.
//  Copyright DerbySoft 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController<UIPopoverControllerDelegate, UISplitViewControllerDelegate, 
	UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
    
    UIPopoverController *popoverController;
    
    id detailItem;
	
	NSMutableArray *contentsOfCurrentFolder;

	UILabel *fullPathLabel;
	UITableView *contentsTableView;
	UIBarItem *syncButton;
}


@property (nonatomic, retain) id detailItem;
@property (nonatomic, retain) IBOutlet UILabel *fullPathLabel;
@property (nonatomic, retain) IBOutlet UITableView *contentsTableView;
@property (nonatomic, retain) IBOutlet UIBarItem *syncButton;

- (IBAction)syncAll;

@end
