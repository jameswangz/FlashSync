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
	NSArray *navigationItems;
}

@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;

@end
