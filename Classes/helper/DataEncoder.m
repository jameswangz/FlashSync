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
	char *bytes = (char *) [data bytes];

	for (int i = 0; i < [data length]; i++) {
		unsigned char decodedBytes[1];
		decodedBytes[0] = bytes[i] ^ 2;
		[decoded appendBytes: decodedBytes length:1];
	}
}

@end
