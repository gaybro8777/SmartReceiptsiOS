//
//  DatabaseDatesTest.m
//  SmartReceipts
//
//  Created by Jaanus Siim on 09/05/15.
//  Copyright (c) 2015 Will Baumann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DatabaseTestsBase.h"
#import "Database+Trips.h"
#import "DatabaseTestsHelper.h"
#import "WBTrip.h"
#import "WBReceipt.h"
#import "NSDate+Calculations.h"

@interface Database (TestExpose)

- (NSArray *)allReceipts;

@end

@interface DatabaseDatesTest : DatabaseTestsBase

@end

@implementation DatabaseDatesTest

- (void)testTripDatesSavedTheOldWayAreReadCorrectly {
    Database *database = [self createAndOpenUnmigratedDatabaseWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"receipts-dates-test" ofType:@"db"]];

    NSArray *trips = [database allTrips];

    XCTAssertEqual(3, trips.count);
    for (WBTrip *trip in trips) {
        XCTAssertTrue([self hasSaneYear:trip.startDate]);
        XCTAssertTrue([self hasSaneYear:trip.endDate]);
    }
}

- (void)testReceiptDatesSavedTheOldWayAreReadCorrectly {
    Database *database = [self createAndOpenUnmigratedDatabaseWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"receipts-dates-test" ofType:@"db"]];

    NSArray *receipts = [database allReceipts];

    XCTAssertEqual(6, receipts.count);
    for (WBReceipt *receipt in receipts) {
        XCTAssertTrue([self hasSaneYear:receipt.dateFromDateMs]);
    }
}

- (void)testTripDatesSavedOnAndroidV11 {
    Database *database = [self createAndOpenUnmigratedDatabaseWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"android-receipts-v11" ofType:@"db"]];

    NSArray *trips = [database allTrips];

    XCTAssertEqual(5, trips.count);
    for (WBTrip *trip in trips) {
        XCTAssertTrue([self hasSaneYear:trip.startDate], @"Date for %@: %@", trip.name, trip.startDate);
        XCTAssertTrue([self hasSaneYear:trip.endDate]);
    }
}

- (void)testReceiptDatesSavedOnAndroidV11 {
    Database *database = [self createAndOpenUnmigratedDatabaseWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"android-receipts-v11" ofType:@"db"]];

    NSArray *receipts = [database allReceipts];

    XCTAssertEqual(68, receipts.count);
    for (WBReceipt *receipt in receipts) {
        XCTAssertTrue([self hasSaneYear:receipt.dateFromDateMs]);
    }
}

- (void)testTripDatesSavedOnAndroidV13 {
    Database *database = [self createAndOpenUnmigratedDatabaseWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"android-receipts-v13" ofType:@"db"]];

    NSArray *trips = [database allTrips];

    XCTAssertEqual(1, trips.count);
    for (WBTrip *trip in trips) {
        XCTAssertTrue([self hasSaneYear:trip.startDate]);
        XCTAssertTrue([self hasSaneYear:trip.endDate]);
    }
}

- (BOOL)hasSaneYear:(NSDate *)date {
    // Old implementation and Android version insert milliseconds for dates, but SQLite uses seconds. This means that on iOS
    // side NSDate can't be used when talking with database. Need to do the millisecond conversion. Doing just a sanity check
    // that year not in a distance future, indicating that conversion from database milliseconds to NSDate seconds was not done
    return date.year >= 2012 && date.year <= [NSDate date].year;
}

@end