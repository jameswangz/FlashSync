//
//  RootViewController.h
//  iPadTest
//
//  Created by James Wang on 2/25/11.
//  Copyright 2011 Freeze!. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface RootViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
	UITableView *tableView;
    DetailViewController *detailViewController;
    NSMutableArray *panelItems;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;

- (void)presentWelcomeLogo:(NSString *)username;
- (void)refreshPanelItems;

@end

