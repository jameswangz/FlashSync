//
//  NSString-UDID.m
//  FlashSync
//
//  Created by James Wang on 1/4/11.
//  Copyright 2011 Freeze!. All rights reserved.
//

#import "NSString-UDID.h"


@implementation NSString (UDID)

- (NSString *)unencrypt {
	int lengthOfSeed = [self length] / 2;
	unsigned char seed[lengthOfSeed];
	for (int i = 0; i<lengthOfSeed; i++) {
		unsigned char j = ([self characterAtIndex:(2 * i)] - 65) * 26;
        j += [self characterAtIndex:(2 * i + 1)] - 65;
		seed[i] = j;
	}
	unsigned short int key = 98;
	for(int i = 0; i < lengthOfSeed; i++){
		int current = seed[i];
		seed[i] ^= (key >> 8); // 将密钥移位后与字符异或
		key = (current + key) * 52845 + 22719; // 产生下一个密钥
    }
	return [[[NSString alloc] initWithBytes:seed length:sizeof(seed) encoding:NSASCIIStringEncoding] autorelease];	
}

@end
