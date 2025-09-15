class_name StateMachine
extends Node

## Emits after [signal state_end] when the previous state
## is finished.
signal state_start(started_state: State)

## Emits before [signal state_start] when the previous state
## is finished.
signal state_end(end_state: State)

## Current [State] the actor is in.
var state: State:
	set(v):
		if is_instance_valid(state):
			state._on_state_end()
			state_end.emit(state)
		state = v
		v._on_state_start()
		state_start.emit(v)

## The previous [Action] that was called through [method handle_action].
var current_action: Action


## Finds the state as a [GDScript], assuming it's already a node that
## exists under this StateMachine node. It allows for clean syntax,
## like get_state(StateMove).
func get_state(state_type: GDScript) -> State:
	for node: Node in get_children():
		var state_node := node as State
		assert(state_node, "Child of StateMachine is not a State!")
		if is_instance_of(state_node, state_type) \
				and is_instance_valid(state_node):
			return state_node

	printerr("Couldn't find State: ", state_type.get_global_name())
	return null


func _process(delta: float) -> void:
	assert(state)
	if is_instance_valid(state):
		state._tick(delta)


func _physics_process(delta: float) -> void:
	assert(state)
	if is_instance_valid(state):
		state._physics_tick(delta)


## Passes the [Action] to the current [State], as well as sets
## [member current_action] to the submitted action.
func _action_process(action: Action) -> void:
	current_action = action
	if is_instance_valid(state):
		state._handle_action(action)


func handle_action(action: Action) -> void:
	_action_process(action)


## Interrupts and immediately changes the current [State].
## If wanting to wait for the state to finish instead, use [method queue_state].
func change_state(new_state: GDScript) -> void:
	assert(new_state)
	var state_node: State = get_state(new_state)
	if is_instance_valid(state_node):
		state = state_node


## Similar to [method change_state], but waits for the current [State]
## to finish before changing.
func queue_state(new_state: GDScript) -> void:
	## TODO: Implement lol.
	change_state(new_state)


## TODO: Implement being able to freeze the current running [State] node.
## Perhaps should just freeze the process. The parent actor should
## be unaffected.
func pause_state() -> void:
	pass
