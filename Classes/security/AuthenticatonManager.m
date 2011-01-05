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

+ (NSString *)udidFromFlashDisk {
	NSString *keyDatPath = [NSDataUtils pathForFolder:kFlashDisk name:@"/ipad_documents/key.dat"];
	NSString *content = [NSString stringWithContentsOfFile:keyDatPath encoding:NSASCIIStringEncoding error:nil];
	NSArray *contents = [content componentsSeparatedByString:@"\n"];
	if (contents.count < 2) {
		return nil;
	}
	NSString *encryptedUdid = [contents objectAtIndex:1];	
	NSLog(@"Encrypted udid %@", encryptedUdid);
	return [encryptedUdid unencrypt];
	
	//	return [self unencryptUdid:@"CNFKDADGHXJTBZBUIFIYFBAWIHIU"];
}

+ (BOOL)authenticate {
	NSString *udid = [[UIDevice currentDevice] uniqueIdentifier];
	NSString *udidFromFlashDisk = [self udidFromFlashDisk];
	NSLog(@"Unencrypted udid %@", udidFromFlashDisk);
	
	BOOL authSuccessful = [udid isEqualToString:udidFromFlashDisk];
	//FIXME just for test, remove it in production
	//authSuccessful = YES;
	
	if (!authSuccessful) {
		[[NSString stringWithFormat:@"对不起, 您的 iPad UDID 与优盘不匹配"] showInDialogWithTitle:@"错误信息"];
		return NO;		
	}
	return YES;
}
@end
