    //
//  InspectorViewController.m
//  FlashSync
//
//  Created by James Wang on 12/12/10.
//  Copyright 2010 DerbySoft. All rights reserved.
//

#import "InspectorViewController.h"


@implementation InspectorViewController

@synthesize url;
@synthesize webView;

- (void)closeView {
	[self dismissModalViewControllerAnimated:YES];
}

- (void) initNavigationBar {
	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" 
																	style:UIBarButtonItemStyleDone 
																   target:self 
																   action:@selector(closeView)];
	self.navigationItem.rightBarButtonItem = closeButton;
	[closeButton release];

}
- (void)viewDidLoad {
	[self initNavigationBar];
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
	[webView loadRequest:request];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}


- (void)viewDidUnload {
    [super viewDidUnload];
    self.url = nil;
	self.webView = nil;
}


- (void)dealloc {
	[url release];
	[webView release];
    [super dealloc];
}


@end
