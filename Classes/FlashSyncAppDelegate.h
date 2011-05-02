//
//  FlashSyncAppDelegate.h
//  FlashSync
//
//  Created by James Wang on 11/28/10.
//  Copyright DerbySoft 2010. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RootViewController;
@class DetailViewController;
@class FileSynchronizer;

@interface FlashSyncAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    
    UISplitViewController *splitViewController;
    
    RootViewController *rootViewController;
    DetailViewController *detailViewController;
	UINavigationController *detailNavigationController;
	
	NSArray *detailViewToolbarItems;	
	BOOL working;
	NSString *workName;
	
	BOOL userCancelled;
	FileSynchronizer *fileSynchronizer;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;
@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
@property (nonatomic, retain) IBOutlet UINavigationController *detailNavigationController;

@property (nonatomic, retain) NSArray *detailViewToolbarItems;
@property (nonatomic) BOOL working;
@property (nonatomic, retain) NSString *workName;

@property (nonatomic) BOOL userCancelled;
@property (nonatomic, retain) FileSynchronizer *fileSynchronizer;

@end
