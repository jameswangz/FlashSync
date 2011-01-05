//
//  NSString-UDIDTest.m
//  FlashSync
//
//  Created by James Wang on 1/4/11.
//  Copyright 2011 Freeze!. All rights reserved.
//


#import <SenTestingKit/SenTestingKit.h>
#import "NSString-UDID.h"

@interface NSString_UDIDTest : SenTestCase {
	
}

@end

@implementation NSString_UDIDTest

- (void)testUnecrypt {
	NSString *unencrypted1 = [@"CNFKDADGHXJTBZBUIFIYFBAWIHIU" unencrypt];
	NSLog(@"Unencrypted1 --- %@", unencrypted1);
	STAssertTrue([@"ADFJKAFJKLSA20" isEqualToString:unencrypted1], @"Not Equal");
	NSString *unencrypted2 = [@"CDFAFSAZJDJMJVCJIODUGLFKBBFVEEJJJADVGUFFHDHMANCCFKADBXGNAAAKEKEQAFIBAZDOBIEDAPDQ" unencrypt];
	NSLog(@"Unencrypted2 --- %@", unencrypted2);
	STAssertTrue([@"75d182c70b85cd038f4089f6ee934eef39ed9517" isEqualToString:unencrypted2], @"Not Equal");	
	NSString *unencrypted3 = [@"7ECB8E2D-470D-5CEE-B258-9305343AAC40 encrypted" unencrypt];
	NSLog(@"Unencrypted2 --- %@", unencrypted3);
	STAssertTrue([@"7ECB8E2D-470D-5CEE-B258-9305343AAC40" isEqualToString:unencrypted3], @"Not Equal");		
}

@end
