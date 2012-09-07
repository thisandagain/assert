//
//  EDFuzz.m
//  connect
//
//  Created by Andrew Sliwinski on 9/7/12.
//  Copyright (c) 2012 DIY, Co. All rights reserved.
//

#import "EDFuzz.h"

@implementation EDFuzz

+ (NSString *)withLength:(NSUInteger)length
{
    NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789!@#$%^&*()_+{}|][=-';:`~? ";
    NSMutableString *s = [NSMutableString stringWithCapacity:length];
    for (NSUInteger i = 0U; i < length; i++) {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    
    return s;
}

@end
