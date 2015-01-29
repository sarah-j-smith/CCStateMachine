#import "MainScene.h"

#import "CCStateMachine.h"
#import "CCStateMachineBuilder.h"

static int MainSceneContext = 0;

@implementation MainScene
{
    CCTime _stateChangeTimer;
    CCStateMachine *_stateMachine;
    
    CCLabelTTF *_label;
    CCLabelTTF *_stateLabel;
}

- (void)initializeStateMachine
{
    CCStateMachineBuilder *builder = [CCStateMachineBuilder stateMachineBuilderWithStates:@[ @"start", @"high", @"low" ]];
    CGPoint pos = [_label positionInPoints];
    CGPoint high = ccp(pos.x, pos.y+10);
    CGPoint low = ccp(pos.x, pos.y-10);
    
    // Set up our State Machine's transitions
    [builder addTransitionFromState:@"start" toState:@"high" onEvent:@"toggle"];
    [builder addTransitionFromState:@"high" toState:@"low" onEvent:@"toggle"];
    [builder addTransitionFromState:@"low" toState:@"high" onEvent:@"toggle"];
    
    // Bind some CCNodes to some values so they get updated when a state is entered
    [builder bind:_label toState:@"high" withKeyPath:@"positionInPoints" toValue:[NSValue valueWithCGPoint:high]];
    [builder bind:_label toState:@"low" withKeyPath:@"positionInPoints" toValue:[NSValue valueWithCGPoint:low]];
    [builder bind:_stateLabel toState:@"low" withKeyPath:@"string" toValue:@"LOW"];
    [builder bind:_stateLabel toState:@"high" withKeyPath:@"string" toValue:@"HIGH"];
    
    _stateMachine = [builder generateStateMachineWithName:@"Cocos State Machine"];
}

- (void)didLoadFromCCB
{
}

- (void)onEnter
{
    [super onEnter];
    [self initializeStateMachine];
    
    _stateChangeTimer = 10;
    [_stateMachine run];

    [_label addObserver:self forKeyPath:@"position" options:NSKeyValueObservingOptionNew context:&MainSceneContext];
}

- (void)onExit
{
    [super onExit];
    [_stateMachine pause];
}

- (void)update:(CCTime)delta
{
    _stateChangeTimer -= delta;
    if (_stateChangeTimer <= 0.0)
    {
        NSLog(@"About to toggle");
        [_stateMachine trigger:@"toggle"];
        _stateChangeTimer = 10;
        NSLog(@"Done with toggle");
    }
    
}

- (void)buttonClicked:(id)sender
{
    NSLog(@"About to toggle");
    [_stateMachine trigger:@"toggle"];
    _stateChangeTimer = 10;
    NSLog(@"Done with toggle");
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != &MainSceneContext)
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    NSLog(@"%@ of %@ changed to %@", keyPath, object, [change objectForKey:NSKeyValueChangeNewKey]);
}

@end
