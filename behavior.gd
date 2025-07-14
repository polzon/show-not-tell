class_name BehaviorSingleton
extends Node

## Tha singleton.
static var _singleton: BehaviorSingleton:
	get():
		if Behavior:
			_singleton = Behavior
		else:
			_singleton = BehaviorSingleton.new()
		return _singleton

## Links to itself lol.
const BEHAVIOR_GD_PATH := "behavior.gd"


## Returns an object reference to the singleton.
## If the behavior autoload is enabled, it will prefer and
## try to return that instead.
static func get_ref() -> BehaviorSingleton:
	return _singleton
