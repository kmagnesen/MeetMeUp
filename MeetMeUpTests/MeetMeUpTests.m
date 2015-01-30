//
//  MeetMeUpTests.m
//  MeetMeUpTests
//
//  Created by Dave Krawczyk on 9/8/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Event.h"

@interface MeetMeUpTests : XCTestCase

@property Event *event;
@property Event *event2;
@end

@implementation MeetMeUpTests

- (void)setUp {
    [super setUp];
}

- (void)testSetUp {

    self.event = [[Event alloc]init];
    NSMutableArray *things = [NSMutableArray new];
    for (int i = 0; i < 15; i++){
        NSString *newString = [NSString stringWithFormat:@"Object %i", i];
        [things addObject:newString];
    }

    [self.event isEqual:things];
    NSLog(@"%@", things);
}

- (void)tearDown {
    [super tearDown];
}

- (void)testLocalMobileEvents {
    [Event performSearchWithKeyword:@"mobile" andComplete:^(NSArray *events) {
        XCTAssertEqual(15, events.count);
    }];
}

- (void)testComments {
    [Event performSearchWithKeyword:@"mobile" andComplete:^(NSArray *events) {
        Event *targetEvent = [events objectAtIndex:1];
        NSString *commentFile = [NSString stringWithFormat:@"commentsData_%@", targetEvent.eventID];
        NSString *path = [[NSBundle mainBundle] pathForResource:commentFile ofType:nil];

        NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
        NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];


        NSArray *comments = [Comment objectsFromArray:[jsonArray objectForKey:@"results"]];

        Comment *comment = comments.firstObject;

        XCTAssertEqual(1, comments.count);
        XCTAssertEqualObjects(@"99045732", [comment.memberID description]);
    }];
}

- (void) testKeywordMobileArray {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for array count"];
    [Event performSearchWithKeyword:@"mobile" andComplete:^(NSArray *events) {
        XCTAssert(events.count == 15);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testEventCommentCountStartAtZero{
    XCTAssert(self.event.commentsArray.count == 0);
}

- (void)testAttendanceCountIncrement
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for comments to return"];

    [Event performSearchWithKeyword:@"mobile" andComplete:^(NSArray *events) {

        Event *secondEvent = [events objectAtIndex:1];

        int attendingCount = [[secondEvent RSVPCount] intValue];
        secondEvent.attending = YES;
        XCTAssertEqual(+ attendingCount, [[secondEvent RSVPCount] intValue]);

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testAttendanceCountDecrement
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for comments to return"];

    [Event performSearchWithKeyword:@"mobile" andComplete:^(NSArray *events) {

        Event *secondEvent = [events objectAtIndex:1];

        secondEvent.attending = YES;
        int attendingCount = [[secondEvent RSVPCount] intValue];
        secondEvent.attending = NO;
        XCTAssertEqual(- -attendingCount, [[secondEvent RSVPCount] intValue]);

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testAttendanceBooleanManagedProperly
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for comments to return"];

    [Event performSearchWithKeyword:@"mobile" andComplete:^(NSArray *events) {

        Event *secondEvent = [events objectAtIndex:1];

        secondEvent.attending = YES;

        XCTAssertEqual(secondEvent.attending, YES);

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:nil];

}

@end
