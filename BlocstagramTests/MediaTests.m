//
//  MediaTests.m
//  Blocstagram
//
//  Created by Amanda Pi on 2015-03-13.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Media.h"

@interface MediaTests : XCTestCase

@end

@implementation MediaTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)testThatInitializationWorks
{
     NSDictionary *sourceDictionary = @{@"id": @"8675309",
                                        @"images" : @{@"standard_resolution" : @{@"url" : @"http://www.bloc.io"}},
                                        @"user_had_liked" : @YES,
                                        @"caption" : @{@"text" : @"Caption text"},
                                        @"user" : @{@"id" : @"8675309",
                                                    @"username" : @"Amanda",
                                                    @"full_name" : @"Amanda Pi",
                                                    @"profile_picture" : @"@http://www.example.com/example.jpg"}
                                        };
    
    Media *testMedia = [[Media alloc] initWithDictionary:sourceDictionary];
    
    XCTAssertEqualObjects(testMedia.idNumber, sourceDictionary[@"id"], @"The ID number should be equal");
    XCTAssertEqualObjects(testMedia.image, sourceDictionary[@"image"], @"The image should be equal");
    XCTAssertNotNil(testMedia.user, @"The user is not nil");
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
