//
//  NSString-Extension.m
//  FlashSync
//
//  Created by James Wang on 4/24/11.
//  Copyright 2011 Freeze!. All rights reserved.
//

#import "NSString-Extension.h"


@implementation NSString (Extension)

- (NSString *)stringByDeletingFirstPathComponent {
	NSMutableArray *components = [[NSMutableArray alloc] initWithArray:[self pathComponents]];
	[components removeObjectAtIndex:0];
	NSString *firstPathRemoved = [NSString pathWithComponents:components];
	//NSLog(@"dstRelativepath %@", firstPathRemoved);
	[components release];
	return firstPathRemoved;
}

@end
