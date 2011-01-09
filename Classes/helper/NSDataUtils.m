//
//  ImageCache.m
//  Cosplaying
//
//  Created by James Wang on 9/22/10.
//  Copyright 2010 Freeze!. All rights reserved.
//

#import "NSDataUtils.h"


@implementation NSDataUtils

+ (NSString *)documentsDirectory {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

+ (NSString *)pathForFolder:(NSString *) folder {
	NSString *path = [[self documentsDirectory] stringByAppendingPathComponent:folder];
	return path;
}

+ (NSString *)pathForFolder:(NSString *) folder name:(NSString *) name {
	return [[self pathForFolder:folder] stringByAppendingPathComponent:name];
}

+ (BOOL)dataExistsInFolder:(NSString *) folder name:(NSString *) name {
	NSString *localDataPath = [self pathForFolder:folder name:name];
	return [[NSFileManager defaultManager] fileExistsAtPath:localDataPath];		
} 

+ (NSData *)loadDataInFolder:(NSString *) folder name:(NSString *) name {
	return [[[NSData alloc] initWithContentsOfFile:[self pathForFolder:folder name:name]] autorelease];
}

+ (void)createFolderIfRequired:(NSString *) folder absolutePath:(BOOL) absolutePath {
	NSString *path = nil;
	if (absolutePath) {
		path = folder;
	} else {
		path = [self pathForFolder:folder];
	}
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL exists = [fileManager fileExistsAtPath:path isDirectory:nil];
	if (!exists) {
		NSError *error = nil;
		[fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
		if (error != nil) {
			NSLog(@"%@", error);
		} else {
			NSLog(@"Created folder %@ successfully.", path);
		}
	}
}

+ (void) createFolderIfRequired:(NSString *) folder {
	[self createFolderIfRequired:folder absolutePath:NO];
}

+ (void)saveData:(NSData *) data inFolder:(NSString *) folder name:(NSString *) name {
	[self createFolderIfRequired:folder];
	[data writeToFile:[self pathForFolder:folder name:name] atomically:YES];
}

+ (Boolean) isDirectory:(NSString *)fullPath {
	NSError *error = nil;
	NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&error];
	if (error != nil) {
		NSLog(@"%@", error);
	}
	id type = [attrs objectForKey:NSFileType];
	return type == NSFileTypeDirectory;		

}

@end
