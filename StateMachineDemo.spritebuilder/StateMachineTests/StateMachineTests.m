//
//  StateMachineTests.m
//  StateMachineTests
//
//  Created by Sarah Smith on 29/01/2015.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "CCStateMachineBuilder.h"
#import "CCStateMachine.h"
#import "CCStateTransition.h"
#import "CCStateBinding.h"

#import "TransitionKit.h"

@interface MockLabel : NSObject

@property (nonatomic, assign) NSPoint position;
@property (nonatomic, strong) NSString *string;

@end

@implementation MockLabel

//

@end

@interface StateMachineTests : XCTestCase

@end

@implementation StateMachineTests
{
    MockLabel *_label;
    MockLabel *_stateLabel;
}

- (void)setUp {
    [super setUp];
    
    _label = [[MockLabel alloc] init];
    _stateLabel = [[MockLabel alloc] init];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    _label = nil;
    _stateLabel = nil;
}

- (void)testCCStateMachine {
    // This is an example of a performance test case.
    CCStateMachineBuilder *builder = [CCStateMachineBuilder stateMachineBuilderWithStates:@[ @"begin", @"attack", @"idle", @"flee", @"chase" ]];
    NSPoint pos = [_label position];
    NSPoint high = CGPointMake(pos.x, pos.y+10);
    NSPoint low = CGPointMake(pos.x, pos.y-10);
    
    // Set up our State Machine's transitions
    [builder addTransitionFromState:@"begin" toState:@"idle" onEvent:@"enter"];
    [builder addTransitionFromState:@"idle" toState:@"chase" onEvent:@"enemyVisible"];
    [builder addTransitionFromState:@"chase" toState:@"attack" onEvent:@"enemyInRange"];
    [builder addTransitionFromState:@"chase" toState:@"flee" onEvent:@"hitPointsLow"];
    [builder addTransitionFromState:@"flee" toState:@"idle" onEvent:@"enemyNotVisible"];
    
    // Bind some CCNodes to some values so they get updated when a state is entered
}

- (void)testPerformanceCCStateMachine
{
    // This is an example of a performance test case.
    CCStateMachineBuilder *builder = [CCStateMachineBuilder stateMachineBuilderWithStates:@[ @"start", @"high", @"low" ]];
    NSPoint pos = [_label position];
    NSPoint high = CGPointMake(pos.x, pos.y+10);
    NSPoint low = CGPointMake(pos.x, pos.y-10);
    
    // Set up our State Machine's transitions
    [builder addTransitionFromState:@"start" toState:@"high" onEvent:@"toggle"];
    [builder addTransitionFromState:@"high" toState:@"low" onEvent:@"toggle"];
    [builder addTransitionFromState:@"low" toState:@"high" onEvent:@"toggle"];
    
    // Bind some CCNodes to some values so they get updated when a state is entered
    [builder bind:_label toState:@"high" withKeyPath:@"position" toValue:[NSValue valueWithPoint:high]];
    [builder bind:_label toState:@"low" withKeyPath:@"position" toValue:[NSValue valueWithPoint:low]];
    [builder bind:_stateLabel toState:@"low" withKeyPath:@"string" toValue:@"LOW"];
    [builder bind:_stateLabel toState:@"high" withKeyPath:@"string" toValue:@"HIGH"];
    
    CCStateMachine *machine = [builder generateStateMachineWithName:@"Cocos State Machine"];
    
    [machine run];
    XCTAssertEqual([machine currentState], @"start", @"Should be start on initial state");
    
    [machine trigger:@"toggle"];
    XCTAssertEqualObjects([machine currentState], @"high", @"Toggle from start -> high");
    XCTAssertEqual(_label.position.x, high.x);
    XCTAssertEqual(_label.position.y, high.y);
    XCTAssertEqualObjects(_stateLabel.string, @"HIGH");
    
    [machine trigger:@"toggle"];
    XCTAssertEqualObjects([machine currentState], @"low", @"Toggle from start -> high");
    XCTAssertEqual(_label.position.x, low.x);
    XCTAssertEqual(_label.position.y, low.y);
    XCTAssertEqualObjects(_stateLabel.string, @"LOW");
    
    NSDate *methodStart = [NSDate date];
    
    for (NSUInteger i = 0; i < 100000; ++i)
    {
        [machine trigger:@"toggle"];
        [machine trigger:@"toggle"];
    }
    
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    NSLog(@"executionTime CCStateMachine = %f", executionTime);
    
    
    [self measureBlock:^{
        for (NSUInteger i = 0; i < 100000; ++i)
        {
            [machine trigger:@"toggle"];
            [machine trigger:@"toggle"];
        }
    }];
}

- (void)testPerformanceTKStateMachine
{
    NSPoint pos = [_label position];
    NSPoint high = CGPointMake(pos.x, pos.y+10);
    NSPoint low = CGPointMake(pos.x, pos.y-10);
    
    TKStateMachine *machine = [[TKStateMachine alloc] init];
    TKState *startState = [TKState stateWithName:@"start"];
    TKState *highState = [TKState stateWithName:@"high"];
    TKState *lowState = [TKState stateWithName:@"low"];
    [machine addStates:@[ startState, highState, lowState ]];
    
    TKEvent *toggleEvent = [TKEvent eventWithName:@"toggle" transitioningFromStates:@[ startState, lowState ] toState:highState];
    TKEvent *toggleEvent2 = [TKEvent eventWithName:@"toggle2" transitioningFromStates:@[ highState ] toState:lowState];
    [highState setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
        [_label setPosition:high];
        [_stateLabel setString:@"HIGH"];
    }];
    [lowState setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
        [_label setPosition:low];
        [_stateLabel setString:@"LOW"];
    }];
    [machine addEvents:@[ toggleEvent, toggleEvent2 ]];
    [machine setInitialState:startState];
    [machine activate];
    
    XCTAssertEqualObjects([[machine currentState] name], @"start", @"Should be start on initial state");
    
    [machine fireEvent:@"toggle" userInfo:nil error:nil];
    XCTAssertEqualObjects([[machine currentState] name], @"high", @"Toggle from start -> high");
    XCTAssertEqual(_label.position.x, high.x);
    XCTAssertEqual(_label.position.y, high.y);
    XCTAssertEqualObjects(_stateLabel.string, @"HIGH");
    
    [machine fireEvent:@"toggle2" userInfo:nil error:nil];
    XCTAssertEqualObjects([[machine currentState] name], @"low", @"Toggle from start -> high");
    XCTAssertEqual(_label.position.x, low.x);
    XCTAssertEqual(_label.position.y, low.y);
    XCTAssertEqualObjects(_stateLabel.string, @"LOW");
    
    NSDate *methodStart = [NSDate date];
    
    for (NSUInteger i = 0; i < 100000; ++i)
    {
        [machine fireEvent:@"toggle" userInfo:nil error:nil];
        [machine fireEvent:@"toggle2" userInfo:nil error:nil];
    }
    
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    NSLog(@"executionTime = %f", executionTime);

    [self measureBlock:^{
        for (NSUInteger i = 0; i < 100000; ++i)
        {
            [machine fireEvent:@"toggle" userInfo:nil error:nil];
            [machine fireEvent:@"toggle2" userInfo:nil error:nil];
        }
    }];
}

@end
