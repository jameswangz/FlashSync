//
//  FileSynchronizer.m
//  FlashSync
//
//  Created by James Wang on 3/12/11.
//  Copyright 2011 Freeze!. All rights reserved.
//

#import "FileSynchronizer.h"
#import "NSObject-Dialog.h"

@implementation FileSynchronizer

@synthesize skip;

- (void)syncFrom:(NSString *)src to:(NSString *)dst {
	if (skip) {
		return;
	}
	
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:dst isDirectory:nil];		
	if (fileExists) {
		[[NSFileManager defaultManager] removeItemAtPath:dst error:nil];
	}
	
	
	NSInputStream *in = [[NSInputStream alloc] initWithFileAtPath:src];
	NSOutputStream *out = [[NSOutputStream alloc] initToFileAtPath:dst append:YES];
	[in open];
	[out open];
	
	static int BUFFER_SIZE = 1024;
	uint8_t buffer[BUFFER_SIZE];
	
	//TODO handle errors
	while (!skip && [in hasBytesAvailable]) {
		int length = [in read:buffer maxLength:BUFFER_SIZE];
		if (![out hasSpaceAvailable]) {
			[@"iPad 上磁盘空间不足" showInDialog];
			[[NSFileManager defaultManager] removeItemAtPath:dst error:nil];
			break;
		}
		[out write:buffer maxLength:length];
	}
	
	[in close];
	[in release];
	[out close];
	[out release];
	
	if (skip) {
		[[NSFileManager defaultManager] removeItemAtPath:dst error:nil];
	}
}

@end
