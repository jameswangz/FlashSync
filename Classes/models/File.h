//
//  File.h
//  FlashSync
//
//  Created by James Wang on 12/4/10.
//  Copyright 2010 DerbySoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface File : NSObject {
	NSString *name;
	NSString *path;
	NSDictionary *attributes;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSDictionary *attributes;

- (id)initWithName:(NSString *)name path:(NSString *)path attributes:(NSDictionary *)attributes;

@end
