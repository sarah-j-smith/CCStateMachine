# CCStateMachine
Experiments with Hierarchical State Machines for Cocos2D/SpriteBuilder

# Current State

Basic FSM is working and can push changes into CCNodes like a CCLabelTTF via programmable bindings.  A demonstration "game" runs on MacOSX and on iOS to show this.


# Performance

Initial testing against TKStateMachine show that this first iteration of the base FSM of CCStateMachine is around 8x faster than TKStateMachine.  That's based on 100,000 toggle-on, toggle-off operations which push changes into an NSObject with a string property and a CGPoint property.  In the TKStateMachine case the changes are pushed into the object via a block set on the didEnterState handler of the machine; in the CCStateMachine case its done with bindings.  The main thing here is that since the bindings are using KVC you might expect them to be slow but they perform pretty well and are definitely not slower than a current best-in-class FSM implementation.
