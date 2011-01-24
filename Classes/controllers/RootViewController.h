//
//  RootViewController.h
//  FlashSync
//
//  Created by James Wang on 11/28/10.
//  Copyright DerbySoft 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface RootViewController : UITableViewController {
    DetailViewController *detailViewController;
	NSMutableArray *panelItems;
}

@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;

- (void)presentWelcomeLogo:(NSString *)username;
- (void)refreshPanelItems;

@end
