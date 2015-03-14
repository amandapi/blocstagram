//
//  ComposeCommentViewTests.m
//  Blocstagram
//
//  Created by Amanda Pi on 2015-03-14.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ComposeCommentView.h"

@interface ComposeCommentViewTests : XCTestCase

@end

@implementation ComposeCommentViewTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}
    
- (void) testForWritingYESifThereIsText {
 
    ComposeCommentView *view = [[ComposeCommentView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    view.text = @"There is text";
    
    XCTAssertTrue(view.isWritingComment, @"is writing comment");
 }

//- (void) testThatSetTextNoWorks {

- (void) testForWritingNOifThereIsNoText {
    
    ComposeCommentView *view = [[ComposeCommentView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    view.text = @"";
    
    XCTAssertTrue(!view.isWritingComment, @"no is writing comment");
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
