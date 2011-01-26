//
//  File.h
//  FlashSync
//
//  Created by James Wang on 12/4/10.
//  Copyright 2010 DerbySoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#define K 1024

@interface File : NSObject {
	NSString *name;
	NSString *path;
	NSDictionary *attributes;
	BOOL selectected;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSDictionary *attributes;
@property (nonatomic, retain) NSString *size;
@property (nonatomic, retain) NSString *modifiedAt;
@property (nonatomic) BOOL selected;
@property (nonatomic, retain) UIImage *image; 

- (id)initWithName:(NSString *)name path:(NSString *)path attributes:(NSDictionary *)attributes;

- (BOOL)isDir;


@end
