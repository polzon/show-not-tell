class_name StateMachine
extends BehaviorControl
## Implemntation of a Finite State Machine.

# TODO: There are still instances of [Actor] left over in [State] that I need
#       to remove for this addon to remain portable.

## Emits after [signal state_end] when the previous state
## is finished.
signal state_start(started_state: State)

## Emits before [signal state_start] when the previous state
## is finished.
signal state_end(end_state: State)

var _process_usec: int = 0
var _physics_usec: int = 0
var _action_usec: int = 0

## Current [State] the actor is in.
var state: State:
	set(v):
		if is_instance_valid(state):
			state._on_state_end()
			state_end.emit(state)
		state = v
		state._on_state_start()
		state_start.emit(state)
## The previous [Action] that was called through [method handle_action].
var current_action: Action

@export_group("Performance Warnings")

@export_custom(PROPERTY_HINT_GROUP_ENABLE, "")
var performance_warning_enabled: bool = false:
	get():
		if not OS.is_debug_build():
			return false
		return performance_warning_enabled
## The elapsed time threshold in micro-seconds that a function should take to
## run before triggering a warning.
@export_range(1, 10000) var warning_threshold: int = 500


## Finds the state as a [GDScript], assuming it's already a node that
## exists under this StateMachine node. It allows for clean syntax,
## like get_state(StateMove).
func get_state(state_type: GDScript) -> State:
	for node: Node in get_children():
		var state_node := node as State
		assert(state_node, "Passed gdscript is not a State object!")
		if state_node \
				and is_instance_of(state_node, state_type):
			return state_node

	printerr("Couldn't find State: ", state_type.get_global_name())
	return null


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		set_process(false)
		return

	if is_instance_valid(state):
		_process_usec = Time.get_ticks_usec()
		state._tick(delta)
		_process_usec = Time.get_ticks_usec() - _process_usec
		_measure_performance()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		set_physics_process(false)
		return

	if is_instance_valid(state):
		_physics_usec = Time.get_ticks_usec()
		state._physics_tick(delta)
		_physics_usec = Time.get_ticks_usec() - _physics_usec


## Passes the [Action] to the current [State], as well as sets
## [member current_action] to the submitted action.
func _action_process(action: Action) -> void:
	current_action = action
	if is_instance_valid(state):
		state._handle_action(action)


func _measure_performance() -> void:
	if not performance_warning_enabled or not current_action:
		return

	var current_script: Script = current_action.get_script()
	var script_name := current_script.get_global_name()
	var actor_name: String = \
			str(current_action.actor.name) \
			if is_instance_valid(current_action.actor) \
			else "<invalid>"

	var warning_prefix := "%s/%s:" % [actor_name, script_name]
	if _process_usec >= warning_threshold:
		push_warning("%s Process tick elapsed %s usecs." \
				% [warning_prefix, _process_usec])
	if _physics_usec >= warning_threshold:
		push_warning("%s Physics tick elapsed %s usecs." \
				% [warning_prefix, _physics_usec])
	if _action_usec >= warning_threshold:
		push_warning("%s Action processed in %s usecs." \
				% [warning_prefix, _action_usec])



func handle_action(action: Action) -> void:
	_action_usec = Time.get_ticks_usec()
	_action_process(action)
	_action_usec = Time.get_ticks_usec() - _action_usec


## Interrupts and immediately changes the current [State].
## If wanting to wait for the state to finish instead, use [method queue_state].
func change_state(new_state: GDScript) -> void:
	var state_node := get_state(new_state)
	if state_node:
		state = state_node
