//
//  StateMachineBuilder.h
//  StateMachineDemo
//
//  Created by Sarah Smith on 28/01/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCStateMachine;

@interface CCStateMachineBuilder : NSObject

/** Return a dictionary of the state machines data.  This is used to construct the actual run time CCStateMachine. */
@property (nonatomic, strong, readonly) NSDictionary *stateMachineData;

/** When the state machine is first run it will enter this state, actioning any bindings.  If a State Machine is constructed from this builder object whilst this value is not set to a valid state name, then the first known state will be deemed as the start state. */
@property (nonatomic, strong) NSString *startState;

/** Creates and returns a StateMachineBuilder with the given states. */
+ (CCStateMachineBuilder *)stateMachineBuilderWithStates:(NSArray *)statesList;

/** Creates and returns a run-time state machine using the data set on this State Machine builder.  If machineName is nil, the new State Machine will be named "State Machine".  This method is useful for constructing instances of identical state machines with different names. */
- (CCStateMachine *)generateStateMachineWithName:(NSString *)machineName;

/** Initialises a State Machine with the given states.  Designated initializer. */
- (instancetype)initWithStates:(NSArray *)statesList;

/** Adds the given states to the list of known available states. */
- (void)addStates:(NSArray *)statesList;

/** Adds the given state to the list of named available states, and returns the new (empty) array of bindings for that state. */
- (NSMutableArray *)addState:(NSString *)stateName;

/** Adds the given event to the list of named available events, and returns the new (empty) array of transitions for that state. */
- (NSMutableArray *)addEvent:(NSString *)eventName;

/** Creates a binding of the given boundObject to the given boundState.  Whenever the boundObject enters the given state the value at the keyPath will be set to the supplied value */
- (void)bind:(NSObject *)boundObject toState:(NSString *)boundState withKeyPath:(NSString*)keyPath toValue:(id)value;

/** Adds a transition from the originState to the destinationState that occurs when the given event triggers. */
- (void)addTransitionFromState:(NSString *)originState toState:(NSString *)destinationState onEvent:(NSString *)eventName;

/** Returns the index of the given state in the list of states, or NSNotFound if the state name is not listed. */
- (NSUInteger)indexForState:(NSString *)stateName;

/** Returns the index of the given event in the list of events, of NSNotFound if the event name is not listed. */
- (NSUInteger)indexForEvent:(NSString *)eventName;

@end
