//
//  CCTransition.h
//  StateMachineDemo
//
//  Created by Sarah Smith on 28/01/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCStateTransition : NSObject

@property (nonatomic, assign) NSUInteger originState;
@property (nonatomic, assign) NSUInteger destinationState;

+ (CCStateTransition *)transitionWithOriginStateIndex:(NSUInteger)originIndex toDestinationStateIndex:(NSUInteger)destinationIndex;

- (instancetype)initWithOriginStateIndex:(NSUInteger)originIndex toDestinationStateIndex:(NSUInteger)destinationIndex;

@end
