The SignalCommandMap is an extension for the Robotlegs-AS3 micro-architecture that makes use of AS3-Signals to trigger commands.

[Requires Robotlegs 1.1](http://github.com/robotlegs/robotlegs-framework)

[Here is an example and more details](http://joelhooks.com/2010/02/14/robotlegs-as3-signals-and-the-signalcommandmap-example/)

dependencies:
https://github.com/tschneidereit/SwiftSuspenders/commit/05e527f3bd4fc0a80e2d6293b0ba5f41e57ced44
https://github.com/robotlegs/robotlegs-framework/commit/3da5425f97c8e09f8839a41e1849575083346732
https://github.com/robertpenner/as3-signals/commit/b2b1048dcc31506b5ddd2c5887189b2deb41ccd1
Note: Use PrioritySignal in GuardedSignalCommandMapTests#three_commands_with_different_guards_fire_correctly, signal_values_passed_to_guards