//
//  AuthenticatonManager.m
//  FlashSync
//
//  Created by James Wang on 1/5/11.
//  Copyright 2011 Freeze!. All rights reserved.
//

#import "AuthenticatonManager.h"
#import "FlashSyncAppDelegate.h"
#import "NSDataUtils.h"
#import "Constants.h"
#import "NSString-UDID.h"
#import "NSObject-Dialog.h"

@implementation AuthenticatonManager

+ (FlashSyncAppDelegate *) appDelegate {
	return [[UIApplication sharedApplication] delegate];
}

+ (void) presentWelcomeLogo:(NSString *)username {
	[[self appDelegate].rootViewController presentWelcomeLogo:username];
}

+ (NSDictionary *)initializeAuthentication {
	NSString *keyDatPath = [NSDataUtils pathForFolder:kFlashDisk name:kKeyDataFileName];
	NSString *content = [NSString stringWithContentsOfFile:keyDatPath encoding:NSASCIIStringEncoding error:nil];
	NSArray *contents = [content componentsSeparatedByString:@"\n"];
	if (contents.count < 2) {
		return nil;
	}
	
	NSString *encryptedUdid = [contents objectAtIndex:1];	
	NSString *udid = [encryptedUdid unencrypt];
	
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setValue:[contents objectAtIndex:0] forKey:@"username"];
	[dict setValue:udid forKey:@"udid"];
	return dict;
}

+ (BOOL)authenticate {
	NSString *udid = [[UIDevice currentDevice] uniqueIdentifier];
	NSDictionary *authentication = [self initializeAuthentication];
	if (authentication == nil) {
		[[NSString stringWithFormat:@"读取身份认证信息失败"] showInDialogWithTitle:@"错误信息"];
		return NO;	
	}
	
	BOOL authSuccessful = [[authentication valueForKey:@"udid"] isEqualToString:udid];
	
	if (!authSuccessful) {
		[[NSString stringWithFormat:@"对不起, 您的身份认证信息与优盘不匹配"] showInDialogWithTitle:@"错误信息"];
		return NO;		
	}
	[self presentWelcomeLogo:[authentication valueForKey:@"username"]];
	return YES;
}
@end
