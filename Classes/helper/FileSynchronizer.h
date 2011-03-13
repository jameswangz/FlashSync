//
//  FileSynchronizer.h
//  FlashSync
//
//  Created by James Wang on 3/12/11.
//  Copyright 2011 Freeze!. All rights reserved.
//
#import <Foundation/Foundation.h>


@interface FileSynchronizer : NSObject {

	BOOL skip;
	NSString *syncingFilePath;
	
}

@property (nonatomic) BOOL skip;

- (void)syncFrom:(NSString *) src to:(NSString *) dst decode:(BOOL) decode;
- (NSString *)syncingFileName;

@end
