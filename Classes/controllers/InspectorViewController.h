//
//  InspectorViewController.h
//  FlashSync
//
//  Created by James Wang on 12/12/10.
//  Copyright 2010 DerbySoft. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface InspectorViewController : UIViewController {
	NSURL *url;
	UIWebView *webView;
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) IBOutlet UIWebView *webView;

@end
