//
//  DetailViewController.h
//  FlashSync
//
//  Created by James Wang on 11/28/10.
//  Copyright DerbySoft 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController<UIPopoverControllerDelegate, UISplitViewControllerDelegate, 
	UITableViewDelegate, UITableViewDataSource> {
    
    UIPopoverController *popoverController;
    
    id detailItem;
	
	NSMutableArray *contentsOfCurrentFolder;

	UILabel *fullPathLabel;
	UITableView *contentsTableView;
}


@property (nonatomic, retain) id detailItem;
@property (nonatomic, retain) IBOutlet UILabel *fullPathLabel;
@property (nonatomic, retain) IBOutlet UITableView *contentsTableView;

- (IBAction)syncAll;

@end
