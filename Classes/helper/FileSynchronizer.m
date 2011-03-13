//
//  FileSynchronizer.m
//  FlashSync
//
//  Created by James Wang on 3/12/11.
//  Copyright 2011 Freeze!. All rights reserved.
//

#import "FileSynchronizer.h"
#import "NSObject-Dialog.h"

@interface FileSynchronizer ()
- (void) removeIfExists: (NSString *) dst;
- (void) decode:(uint8_t*) encoded to:(uint8_t*) decoded length:(int) length;
@end


@implementation FileSynchronizer

@synthesize skip;


- (void)syncFrom:(NSString *)src to:(NSString *)dst decode:(BOOL) decode {
	syncingFilePath = src;
	if (skip) {
		return;
	}
	
	[self removeIfExists: dst];

	NSInputStream *in = [[NSInputStream alloc] initWithFileAtPath:src];
	NSOutputStream *out = [[NSOutputStream alloc] initToFileAtPath:dst append:YES];
	[in open];
	[out open];
	
	static int BUFFER_SIZE = 1024;
	uint8_t buffer[BUFFER_SIZE];
	
	while (!skip && [in hasBytesAvailable]) {
		int length = [in read:buffer maxLength:BUFFER_SIZE];
		if (![out hasSpaceAvailable]) {
			[@"iPad 上磁盘空间不足" showInDialog];
			[self removeIfExists:dst];
			break;
		}
		
		int result;
		if (decode) {
			uint8_t decoded[length];
			[self decode:buffer to:decoded length:length];
			result = [out write:decoded maxLength:length];
		} else {
			result = [out write:buffer maxLength:length];			
		}
		if (result == -1) {
			NSLog(@"Write failed : %d", result);		
		}
	}
	
	[in close];
	[in release];
	[out close];
	[out release];
	
	if (skip) {
		[self removeIfExists:dst];
	}
}

- (void) removeIfExists: (NSString *) dst  {
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:dst isDirectory:nil];		
	if (fileExists) {
		[[NSFileManager defaultManager] removeItemAtPath:dst error:nil];
	}
}

- (void) decode:(uint8_t*) encoded to:(uint8_t*) decoded length:(int) length {
	for (int i = 0; i < length; i++) {
		decoded[i] = encoded[i] ^ 2;
	}
}

- (NSString *)syncingFileName {
	return [syncingFilePath lastPathComponent];
}

@end
