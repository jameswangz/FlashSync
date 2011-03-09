//
//  File.m
//  FlashSync
//
//  Created by James Wang on 12/4/10.
//  Copyright 2010 DerbySoft. All rights reserved.
//

#import "File.h"
#import "NSObject-Dialog.h"

@interface File ()

- (NSString *)imageNameOf:(NSString *)pathExtension;

@end

@implementation File


@synthesize name;
@synthesize path;
@synthesize attributes;
@synthesize size;
@synthesize modifiedAt;
@synthesize image;
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

- (UIImage *)image {
	if ([self isDir]) {
		return [UIImage imageNamed:@"folder.png"];
	}
	
	NSString *imageName = [NSString stringWithFormat:@"%@.png", [name pathExtension]];
	UIImage *theImage = [UIImage imageNamed:imageName];
	if (theImage == nil) {
		theImage = [UIImage imageNamed:[self imageNameOf:[name pathExtension]]];
	}
	if (theImage == nil) {
		theImage = [UIImage imageNamed:@"empty.png"];	
	}
	return theImage;
}

- (NSString *)imageNameOf:(NSString *)pathExtension {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:@"jpeg.png" forKey:@"jpg"];
	[dict setObject:@"doc.png" forKey:@"docx"];
	[dict setObject:@"spreadsheet.png" forKey:@"xls"];
	[dict setObject:@"spreadsheet.png" forKey:@"xlxs"];
	[dict setObject:@"config.png" forKey:@"plist"];
	[dict setObject:@"video.png" forKey:@"avi"];
	[dict setObject:@"video.png" forKey:@"mov"];
	[dict setObject:@"video.png" forKey:@"mp4"];
	[dict setObject:@"mpeg.png" forKey:@"mpg"];	
	[dict setObject:@"zip.png" forKey:@"rar"];
	[dict setObject:@"flash.png" forKey:@"swf"];
	NSString *imageName = [dict objectForKey:pathExtension];
	[dict release];
	return imageName;
}

@end
