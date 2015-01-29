//
//  StateMachineBuilder.m
//  StateMachineDemo
//
//  Created by Sarah Smith on 28/01/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCStateMachineBuilder.h"
#import "CCStateMachine.h"
#import "CCStateTransition.h"
#import "CCStateBinding.h"

@implementation CCStateMachineBuilder
{
    // Maps states to the lists of bindings for that state
    NSMutableDictionary *_states;
    NSMutableArray *_stateIndexes;
    
    // Maps events to the lists of transitions for that event
    NSMutableDictionary *_events;
    NSMutableArray *_eventIndexes;
}

+ (CCStateMachineBuilder *)stateMachineBuilderWithStates:(NSArray *)statesList
{
    return [[CCStateMachineBuilder alloc] initWithStates:statesList];
}

- (NSDictionary *)stateMachineData
{
    NSMutableArray *stateArray = [NSMutableArray array];
    NSMutableArray *eventsArray = [NSMutableArray array];
    NSMutableArray *transitionsArray = [NSMutableArray array];
    NSMutableArray *bindingsArray = [NSMutableArray array];
    for (NSString *stateName in _stateIndexes)
    {
        [stateArray addObject:stateName];
        [bindingsArray addObject:[_states objectForKey:stateName]];
    }
    for (NSString *eventname in _eventIndexes)
    {
        [eventsArray addObject:eventname];
        [transitionsArray addObject:[_events objectForKey:eventname]];
    }
    return @{ @"STATES" : [stateArray copy], @"EVENTS" : [eventsArray copy],
              @"TRANSITIONS" : [transitionsArray copy], @"BINDINGS" : [bindingsArray copy] };
}

- (CCStateMachine *)generateStateMachineWithName:(NSString *)machineName
{
    CCStateMachine *machine = [[CCStateMachine alloc] initWithBuilder:self];
    if (machineName == nil)
    {
        machineName = @"State Machine";
    }
    [machine setMachineName:machineName];
    return machine;
}

- (instancetype)init
{
    return [self initWithStates:nil];
}

- (instancetype)initWithStates:(NSArray *)statesList
{
    self = [super init];
    if (self)
    {
        _states = [NSMutableDictionary dictionary];
        _stateIndexes = [NSMutableArray array];
        _events = [NSMutableDictionary dictionary];
        _eventIndexes = [NSMutableArray array];
        [self addStates:statesList];
    }
    return self;
}

- (NSMutableArray *)addState:(NSString *)stateName
{
    NSMutableArray *bindingsArray = [_states objectForKey:stateName];
    if (bindingsArray == nil)
    {
        bindingsArray = [NSMutableArray array];
        [_states setObject:bindingsArray forKey:stateName];
        [_stateIndexes addObject:stateName];
    }
    return bindingsArray;
}

- (void)addStates:(NSArray *)statesList
{
    if (statesList)
    {
        for (NSString *stateName in statesList)
        {
            [self addState:stateName];
        }
    }
}

- (NSMutableArray *)addEvent:(NSString *)eventName
{
    NSMutableArray *transitionsArray = [_events objectForKey:eventName];
    if (transitionsArray == nil)
    {
        transitionsArray = [NSMutableArray array];
        [_events setObject:transitionsArray forKey:eventName];
        [_eventIndexes addObject:eventName];
    }
    return transitionsArray;
}

- (NSUInteger)indexForState:(NSString *)stateName
{
    return [_stateIndexes indexOfObject:stateName];
}

- (NSUInteger)indexForEvent:(NSString *)eventName
{
    return [_eventIndexes indexOfObject:eventName];
}

- (void)bind:(NSObject *)boundObject toState:(NSString *)boundState withKeyPath:(NSString*)keyPath toValue:(id)value
{
    NSMutableArray *bindingsForState = [_states objectForKey:boundState];
    if (bindingsForState == nil)
    {
        bindingsForState = [self addState:boundState];
        NSLog(@"bindObject toState: \"%@\" *not found* (so it was added)", boundState);
    }
    CCStateBinding *binding = [CCStateBinding bindingWithBoundObject:boundObject forKeyPath:keyPath toValue:value];
    [bindingsForState addObject:binding];
}

- (void)addTransitionFromState:(NSString *)originState toState:(NSString *)destinationState onEvent:(NSString *)eventName
{
    if ([_states objectForKey:originState] == nil)
    {
        [self addState:originState];
        NSLog(@"originState: \"%@\" *not found* (so it was added)", originState);
    }
    if ([_states objectForKey:destinationState] == nil)
    {
        [self addState:destinationState];
        NSLog(@"destinationState: \"%@\" *not found* (so it was added)", destinationState);
    }
    NSMutableArray *transitionsForEvent = [_events objectForKey:eventName];
    if (transitionsForEvent == nil)
    {
        transitionsForEvent = [self addEvent:eventName];
    }
    CCStateTransition *transition = [CCStateTransition transitionWithOriginStateIndex:[self indexForState:originState] toDestinationStateIndex:[self indexForState:destinationState]];
    [transitionsForEvent addObject:transition];
}

@end
