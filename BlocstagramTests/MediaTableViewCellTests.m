//
//  MediaTableViewCellTests.m
//  Blocstagram
//
//  Created by Amanda Pi on 2015-03-14.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MediaTableViewCell.h"
#import "Media.h"

@interface MediaTableViewCellTests : XCTestCase

@end

@implementation MediaTableViewCellTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void) testThatMediaTableViewCellReturnsCorrectHeightForMediaItem {
    
    NSDictionary *sourceDictionary= @{@"id": @"8675309",
                                       @"images" : @{@"standard_resolution" : @{@"url" : @"http://www.bloc.io"}},
                                       @"user_had_liked" : @YES,
                                       @"caption" : @{@"text" : @"Caption text"},
                                       @"user" : @{@"id" : @"8675309",
                                          @"username" : @"Amanda",
                                          @"full_name" : @"Amanda Pi",
                                          @"profile_picture" : @"@http://www.example.com/example.jpg"}
                                      };
    Media *mediaItem = [[Media alloc] initWithDictionary:sourceDictionary];
    
    mediaItem.image = [UIImage imageNamed:@"4.jpg"];
    CGFloat itemHeight = [MediaTableViewCell heightForMediaItem:mediaItem width:320];
    XCTAssertEqual(itemHeight, 414, @"Item height should be 414");

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
