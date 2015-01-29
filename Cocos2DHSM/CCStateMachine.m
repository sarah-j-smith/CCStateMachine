//
//  CCStateMachine.m
//  StateMachineDemo
//
//  Created by Sarah Smith on 28/01/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCStateMachine.h"
#import "CCStateTransition.h"
#import "CCStateMachineBuilder.h"
#import "CCStateBinding.h"

NSString * const CCStateMachineErrorDomain = @"CCStateMachineErrorDomain";

@implementation CCStateMachine
{
    NSArray *_states;
    NSArray *_events;
    NSArray *_transitions;
    NSArray *_bindings;
    
    NSUInteger _currentStateIndex;
    BOOL _isRunning;
}

- (NSString *)currentState
{
    return [_states objectAtIndex:_currentStateIndex];
}

- (void)setCurrentState:(NSString *)currentState
{
    NSUInteger newStateIndex = [_states indexOfObject:currentState];
    if (newStateIndex == NSNotFound)
    {
        NSString *errStr = [NSString stringWithFormat:@"Attempt to setCurrentState to unknown state value: %@", currentState];
        _lastError = [NSError errorWithDomain:CCStateMachineErrorDomain
                                         code:UnknownStateName
                                     userInfo:@{ NSLocalizedDescriptionKey : errStr }];
    }
    else
    {
        [self doTransitionFromState:_currentStateIndex toState:newStateIndex withEvent:nil];
    }
}

+ (CCStateMachine *)stateMachineWithBuilder:(CCStateMachineBuilder *)builder
{
    return [[CCStateMachine alloc] initWithBuilder:builder];
}

- (instancetype)init
{
    return [self initWithBuilder:nil];
}

- (instancetype)initWithBuilder:(CCStateMachineBuilder *)builder
{
    self = [super init];
    if (self)
    {
        if (builder)
        {
            NSDictionary *statesData = [builder stateMachineData];
            _states = [statesData objectForKey:@"STATES"];
            _events = [statesData objectForKey:@"EVENTS"];
            _transitions = [statesData objectForKey:@"TRANSITIONS"];
            _bindings = [statesData objectForKey:@"BINDINGS"];
            NSAssert(_states && _events && _transitions && _bindings, @"Corrupt builder data!");
            NSAssert([_states count] == [_bindings count], @"Builder did not give one-to-one states to bindings!");
            NSAssert([_events count] == [_transitions count], @"Builder did not give one-to-one events to transitions!");
        }
        _currentStateIndex = NSNotFound;
        _startState = [builder startState];
        if (_startState == nil)
        {
            _startState = [_states objectAtIndex:0];
        }
        _isRunning = NO;
    }
    return self;
}

- (BOOL)trigger:(NSString *)eventName
{
    if (!_isRunning)
    {
        NSLog(@"%@ is not running: ignoring trigger: %@", [self machineName], eventName);
        _lastError = nil;
        return NO;
    }
    NSUInteger eventIndex = [_events indexOfObject:eventName];
    if (eventIndex == NSNotFound)
    {
        NSLog(@"Transition %@ not found on state machine: %@", eventName, [self machineName]);
        return NO;
    }
    BOOL success = NO;
    NSArray *transitionsForEvent = [_transitions objectAtIndex:eventIndex];
    for (CCStateTransition *transition in transitionsForEvent)
    {
        NSUInteger origin = [transition originState];
        if (origin == _currentStateIndex)
        {
            [self doTransitionFromState:origin toState:[transition destinationState] withEvent:eventName];
            success = YES;
            break;
        }
    }
    if (!success)
    {
        // This was an illegal transition - the trigger was not valid for the current state
        NSString *errStr = [NSString stringWithFormat:@"Invalid attempt to trigger %@ when in state: %@",
                            eventName, [self currentState]];
        _lastError = [NSError errorWithDomain:CCStateMachineErrorDomain
                                         code:UnknownStateName
                                     userInfo:@{ NSLocalizedDescriptionKey : errStr }];
    }
    return success;
}

- (void)doTransitionFromState:(NSUInteger)sourceState toState:(NSUInteger)destinationState withEvent:(NSString *)eventName
{
    NSAssert(destinationState < [_states count], @"Cannot transition to illegal state!");
    _currentStateIndex = destinationState;
    NSArray *bindingsForState = [_bindings objectAtIndex:_currentStateIndex];
    for (CCStateBinding *binding in bindingsForState)
    {
        NSError *err;
        [binding applyBindingForEvent:eventName fromStateMachine:self error:&err];
        if (err != nil)
        {
            _lastError = [err copy];
        }
    }
}

- (void)run
{
    _isRunning = YES;
    if (_currentStateIndex == NSNotFound)
    {
        [self setCurrentState:_startState];
    }
}

- (void)pause
{
    _isRunning = NO;
}

@end
