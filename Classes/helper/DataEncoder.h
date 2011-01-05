//
//  DataEncoder.h
//  FlashSync
//
//  Created by James Wang on 1/5/11.
//  Copyright 2011 Freeze!. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DataEncoder : NSObject {

}

+ (void) decode: (NSData *) data to: (NSMutableData *) decoded;

@end
