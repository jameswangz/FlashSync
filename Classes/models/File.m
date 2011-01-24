//
//  File.m
//  FlashSync
//
//  Created by James Wang on 12/4/10.
//  Copyright 2010 DerbySoft. All rights reserved.
//

#import "File.h"
#import "NSObject-Dialog.h"

@implementation File


@synthesize name;
@synthesize path;
@synthesize attributes;
@synthesize size;
@synthesize modifiedAt;
@synthesize selected;

- (id)initWithName:(NSString *)theName path:(NSString *)thePath attributes:(NSDictionary *)theAttributes {
	if (self = [super init]) {
		self.name = theName;
		self.path = thePath;
		self.attributes = theAttributes;
		self.selected = NO;
	}
	return self;
}

- (BOOL)isDir {
	id type = [self.attributes objectForKey:NSFileType];
	return type == NSFileTypeDirectory;		
}

- (NSString *)size {
	float thesize = [[attributes objectForKey:NSFileSize] floatValue];
	if (thesize < K) {
		return [NSString stringWithFormat:@"%.2f Bytes", thesize];
	}
	thesize = thesize / K;
	if (thesize < K) {
		return [NSString stringWithFormat:@"%.2f KB", thesize];
	}
	thesize = thesize / K;
	return [NSString stringWithFormat:@"%.2f MB", thesize];
}

- (NSString *)modifiedAt {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSString *formatted = [formatter stringFromDate:[attributes objectForKey:NSFileModificationDate]];
	[formatter release];
	return formatted;
}


@end
