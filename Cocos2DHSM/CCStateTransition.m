//
//  CCTransition.m
//  StateMachineDemo
//
//  Created by Sarah Smith on 28/01/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCStateTransition.h"

@implementation CCStateTransition

+ (CCStateTransition *)transitionWithOriginStateIndex:(NSUInteger)originIndex toDestinationStateIndex:(NSUInteger)destinationIndex
{
    return [[CCStateTransition alloc] initWithOriginStateIndex:originIndex toDestinationStateIndex:destinationIndex];
}

- (instancetype)initWithOriginStateIndex:(NSUInteger)originIndex toDestinationStateIndex:(NSUInteger)destinationIndex
{
    NSAssert(originIndex != NSNotFound, @"Cannot create transition with bad origin!");
    NSAssert(destinationIndex != NSNotFound, @"Cannot create transition with bad destination!");
    self = [super init];
    if (self) {
        _originState = originIndex;
        _destinationState = destinationIndex;
    }
    return self;
}

@end