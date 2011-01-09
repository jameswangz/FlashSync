//
//  ImageCache.h
//  Cosplaying
//
//  Created by James Wang on 9/22/10.
//  Copyright 2010 Freeze!. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDataUtils : NSObject {

}

+ (NSString *)documentsDirectory;
+ (NSString *)pathForFolder:(NSString *) folder;
+ (NSString *)pathForFolder:(NSString *) folder name:(NSString *) name;
+ (void) createFolderIfRequired:(NSString *) folder;
+ (void) createFolderIfRequired:(NSString *) folder absolutePath:(BOOL) absolutePath;
+ (BOOL)dataExistsInFolder:(NSString *) folder name:(NSString *) name; 
+ (NSData *)loadDataInFolder:(NSString *) folder name:(NSString *) name;
+ (void)saveData:(NSData *) data inFolder:(NSString *) folder name:(NSString *) name;
+ (Boolean)isDirectory:(NSString *) fullPath;
@end
