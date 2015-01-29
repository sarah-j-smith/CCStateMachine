//
//  CCStateBinding.h
//  StateMachineDemo
//
//  Created by Sarah Smith on 28/01/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//
#import <Foundation/Foundation.h>

@class CCStateMachine;

@interface CCStateBinding : NSObject

@property (nonatomic, strong) id boundObject;
@property (nonatomic, strong) NSString *keyPath;
@property (nonatomic, strong) id destinationValue;

/** Creates and returns a new binding of an object to a state.  When this binding is applied - for example when the state machine for the object transitions into this state - the given keyPath will have the value set onto it using setValue:forKeyPath: */
+ (CCStateBinding *)bindingWithBoundObject:(id)object forKeyPath:(NSString *)keyPath toValue:(id)finalValue;

/** Initialises a new binding of an object to a state.  When this binding is applied - for example when the state machine for the object transitions into this state - the given keyPath will have the value set onto it using setValue:forKeyPath: */
- (instancetype)initWithBoundObject:(id)object forKeyPath:(NSString *)keyPath toValue:(id)finalValue;

/** Applies this binding.  The boundObject has the destinationValue set onto the keyPath using Key-Value coding. If the binding is successful then this method returns true.  Otherwise it returns false, and the errorPtr value is set. */
- (BOOL)applyBindingForEvent:(NSString *)eventName fromStateMachine:(CCStateMachine *)machine error:(NSError **)errorPtr;

@end
