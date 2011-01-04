//
//  NSString-UDIDTest.m
//  FlashSync
//
//  Created by James Wang on 1/4/11.
//  Copyright 2011 Freeze!. All rights reserved.
//


#import <SenTestingKit/SenTestingKit.h>
#import <Foundation/Foundation.h>
#import "NSString-UDID.h"
#import "NSDataUtils.h"


@interface NSString_UDIDTest : SenTestCase {
	
}

@end

@implementation NSString_UDIDTest

- (void)testUnecrypt {
	NSLog(@"aaa %@", [NSDataUtils pathForFolder:@"aaa"]);
	STAssertTrue([[NSDataUtils pathForFolder:@"aaa"] isEqualToString:[NSDataUtils pathForFolder:@"aaa"]], @"not equal");
	
	
	SEL selector = @selector(unencrypt);
	NSLog(@"Selector %@", selector);
	STAssertEquals(@"ADFJKAFJKLSA20", [@"CNFKDADGHXJTBZBUIFIYFBAWIHIU" performSelector:selector], @"Not Equal");
}

@end
