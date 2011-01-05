//
//  DataEncoder.m
//  FlashSync
//
//  Created by James Wang on 1/5/11.
//  Copyright 2011 Freeze!. All rights reserved.
//

#import "DataEncoder.h"


@implementation DataEncoder

+ (void) decode: (NSData *) data to: (NSMutableData *) decoded  {
	//TODO optimize performance by using buffer
	int totalSize = [data length];
	unsigned char buffer[totalSize];
	unsigned char decodedBuffer[totalSize];
	
	[data getBytes:buffer length:totalSize];
	
	for (int i = 0; i < sizeof(buffer); i++) {
		decodedBuffer[i] = buffer[i] ^ 2;
	}
	
	[decoded appendBytes:decodedBuffer length:totalSize];
}

@end
