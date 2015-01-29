//
//  CCStateBinding.m
//  StateMachineDemo
//
//  Created by Sarah Smith on 28/01/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCStateBinding.h"
#import "CCStateMachine.h"

@implementation CCStateBinding

+ (CCStateBinding *)bindingWithBoundObject:(id)object forKeyPath:(NSString *)keyPath toValue:(id)finalValue
{
    return [[CCStateBinding alloc] initWithBoundObject:object forKeyPath:keyPath toValue:finalValue];
}

- (instancetype)initWithBoundObject:(id)object forKeyPath:(NSString *)keyPath toValue:(id)finalValue
{
    self = [super init];
    if (self) {
        _boundObject = object;
        _keyPath = [keyPath copy];
        _destinationValue = finalValue;
    }
    return self;
}

- (BOOL)applyBindingForEvent:(NSString *)eventName fromStateMachine:(CCStateMachine *)machine error:(NSError **)errorPtr
{
    NSError *err = nil;
    [_boundObject setValue:_destinationValue forKeyPath:_keyPath];
    *errorPtr = err;
    return YES;
}

@end
