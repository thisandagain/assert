//
//  EDAssertEventually.m
//  assert
//
//  Created by Andrew Sliwinski on 9/7/12.
//  Copyright (c) 2012 Andrew Sliwinski. All rights reserved.
//
//  Based on a gist by Luke Redpath <luke@lukeredpath.co.uk>
//

#import "EDAssertEventually.h"

@interface EDTimeout : NSObject
{
    NSDate *timeoutDate;
}
- (id)initWithTimeout:(NSTimeInterval)timeout;
- (BOOL)hasTimedOut;
@end

@implementation EDTimeout

- (id)initWithTimeout:(NSTimeInterval)timeout
{
    self = [super init];
    if (self) {
        timeoutDate = [[NSDate alloc] initWithTimeIntervalSinceNow:timeout];
    }
    return self;
}

- (BOOL)hasTimedOut
{
    return [timeoutDate timeIntervalSinceNow] < 0;
}

@end

#pragma mark - Core

@implementation EDProbePoller

- (id)initWithTimeout:(NSTimeInterval)theTimeout delay:(NSTimeInterval)theDelay;
{
    self = [super init];
    if (self) {
        timeoutInterval = theTimeout;
        delayInterval = theDelay;
    }
    return self;
}

- (BOOL)check:(id<EDProbe>)probe;
{
    EDTimeout *timeout = [[EDTimeout alloc] initWithTimeout:timeoutInterval];
    
    while (![probe isSatisfied]) {
        if ([timeout hasTimedOut]) {
            return false;
        }
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:delayInterval]];
        [probe sample];
    }
    
    return true;
}

@end

void ED_assertEventuallyWithLocationAndTimeout(SenTestCase *testCase, const char* fileName, int lineNumber, id<EDProbe>probe, NSTimeInterval timeout)
{
    EDProbePoller *poller = [[EDProbePoller alloc] initWithTimeout:timeout delay:DEFAULT_PROBE_DELAY];
    if (![poller check:probe]) {
        NSString *failureMessage = [probe describeToString:[NSString stringWithFormat:@"Probe failed after %d second(s). ", (int)timeout]];
        
        [testCase failWithException:
         [NSException failureInFile:[NSString stringWithUTF8String:fileName]
                             atLine:lineNumber
                    withDescription:failureMessage]];
    }
}

void ED_assertEventuallyWithLocation(SenTestCase *testCase, const char* fileName, int lineNumber, id<EDProbe>probe)
{
    ED_assertEventuallyWithLocationAndTimeout(testCase, fileName, lineNumber, probe, DEFAULT_PROBE_TIMEOUT);
}

#pragma mark - Block support

@implementation EDBlockProbe

+ (id)probeWithBlock:(EDBlockProbeBlock)block;
{
    return [[self alloc] initWithBlock:block];
}

- (id)initWithBlock:(EDBlockProbeBlock)aBlock;
{
    self = [super init];
    if (self) {
        block = [aBlock copy];
        isSatisfied = false;
        [self sample];
    }
    return self;
}

- (BOOL)isSatisfied;
{
    return isSatisfied;
}

- (void)sample;
{
    isSatisfied = block();
}

- (NSString *)describeToString:(NSString *)description;
{
    return [description stringByAppendingString:@"Block call did not return positive value."];
}

@end

#pragma mark - Hamcrest support

@implementation EDHamcrestProbe

+ (id)probeWithObjectPointer:(id)objectPtr matcher:(id<HCMatcher>)matcher;
{
    return [[self alloc] initWithObjectPointer:objectPtr matcher:matcher];
}

- (id)initWithObjectPointer:(id)objectPtr matcher:(id<HCMatcher>)aMatcher;
{
    if (self = [super init]) {
        pointerToActualObject = objectPtr;
        matcher = aMatcher;
        [self sample];
    }
    return self;
}

- (BOOL)isSatisfied;
{
    return didMatch;
}

- (void)sample;
{
    didMatch = [matcher matches:[self actualObject]];
}

- (NSString *)describeToString:(NSString *)description;
{
    HCStringDescription* stringDescription = [HCStringDescription stringDescription];
    [[[[stringDescription appendText:@"Expected "] appendDescriptionOf:matcher] appendText:@", got "] appendText:[NSString stringWithFormat:@"%@", [self actualObject]]];
    
    return [description stringByAppendingString:[stringDescription description]];
}

- (id)actualObject
{
    return pointerToActualObject;
}

@end
