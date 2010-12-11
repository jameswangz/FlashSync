//
//  File.m
//  FlashSync
//
//  Created by James Wang on 12/4/10.
//  Copyright 2010 DerbySoft. All rights reserved.
//

#import "File.h"

@implementation File


@synthesize name;
@synthesize path;
@synthesize attributes;

- (id)initWithName:(NSString *)theName path:(NSString *)thePath attributes:(NSDictionary *)theAttributes {
	if (self = [super init]) {
		self.name = theName;
		self.path = thePath;
		self.attributes = theAttributes;
	}
	return self;
}

- (BOOL)isDir {
	id type = [self.attributes objectForKey:NSFileType];
	return type == NSFileTypeDirectory;		
}

@end
