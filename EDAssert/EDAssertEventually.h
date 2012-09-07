//
//  EDAssertEventually.h
//  assert
//
//  Created by Andrew Sliwinski on 9/7/12.
//  Copyright (c) 2012 Andrew Sliwinski. All rights reserved.
//
//  Based on a gist by Luke Redpath <luke@lukeredpath.co.uk>
//

#define HC_SHORTHAND
#define DEFAULT_PROBE_TIMEOUT 2
#define DEFAULT_PROBE_DELAY   0.1

#import <Foundation/Foundation.h>
#import <SenTestingKit/SenTestCase.h>
#import <OCHamcrest/OCHamcrest.h>
#import <OCHamcrest/HCStringDescription.h>

//

@protocol EDProbe <NSObject>
- (BOOL)isSatisfied;
- (void)sample;
- (NSString *)describeToString:(NSString *)description;
@end

@interface EDProbePoller : NSObject
{
    NSTimeInterval timeoutInterval;
    NSTimeInterval delayInterval;
}
- (id)initWithTimeout:(NSTimeInterval)theTimeout delay:(NSTimeInterval)theDelay;
- (BOOL)check:(id<EDProbe>)probe;
@end

//

@class SenTestCase;

void ED_assertEventuallyWithLocationAndTimeout(SenTestCase *testCase, const char* fileName, int lineNumber, id<EDProbe>probe, NSTimeInterval timeout);
void ED_assertEventuallyWithLocation(SenTestCase *testCase, const char* fileName, int lineNumber, id<EDProbe>probe);

#define assertEventuallyWithTimeout(probe, timeout) \
ED_assertEventuallyWithLocationAndTimeout(self, __FILE__, __LINE__, probe, timeout)

#define assertEventually(probe) \
ED_assertEventuallyWithLocation(self, __FILE__, __LINE__, probe)

typedef BOOL (^EDBlockProbeBlock)();

@interface EDBlockProbe : NSObject <EDProbe>
{
    EDBlockProbeBlock block;
    BOOL isSatisfied;
}
+ (id)probeWithBlock:(EDBlockProbeBlock)block;
- (id)initWithBlock:(EDBlockProbeBlock)aBlock;
@end

#define assertEventuallyWithBlockAndTimeout(block,timeout) \
assertEventuallyWithTimeout([EDBlockProbe probeWithBlock:block], timeout)

#define assertEventuallyWithBlock(block) \
assertEventually([EDBlockProbe probeWithBlock:block])

@interface EDHamcrestProbe : NSObject <EDProbe>
{
    id pointerToActualObject;
    id<HCMatcher> matcher;
    BOOL didMatch;
}
+ (id)probeWithObjectPointer:(id)objectPtr matcher:(id<HCMatcher>)matcher;
- (id)initWithObjectPointer:(id)objectPtr matcher:(id<HCMatcher>)aMatcher;
- (id)actualObject;
@end

#define assertEventuallyThatWithTimeout(objectPtr, aMatcher, timeout) \
assertEventuallyWithTimeout([EDHamcrestProbe probeWithObjectPointer:objectPtr matcher:aMatcher], timeout)

#define assertEventuallyThat(objectPtr, aMatcher) \
assertEventually([EDHamcrestProbe probeWithObjectPointer:objectPtr matcher:aMatcher])
