class_name State
extends Node
## Abstract base class for States.
## [br]
## @experimental: When the inspector plugin progresses, I plan on moving this
## away from extending a node, and instead being a resource.


## The [StateMachine] that is handling the [State].
@onready var state_machine: StateMachine:
	get():
		if not state_machine:
			state_machine = get_parent() as StateMachine
		assert(state_machine, "Failed to get StateMachine!")
		return state_machine


## Called from [StateMachine] when an action is passed to it,
## but only when it's the [member current_state].
func _handle_action(_action: Action) -> void:
	pass


func _on_state_start() -> void:
	pass


func _on_state_end() -> void:
	pass


## Similar to [member _physics_update], but only runs when the state is
## the current state.
func _physics_tick(_delta: float) -> void:
	pass


## Similar to [member _process], but only runs when the state is
##  the current state.
func _tick(_delta: float) -> void:
	pass


## Returns the active [State] the [StateMachine] is processing.
func current_state() -> State:
	if is_instance_valid(state_machine):
		return state_machine.state
	else:
		return null


## Returns a [bool] if this state is the current state being processed by the
## [StateMachine].
func is_current_state() -> bool:
	return current_state() == self


## Request the [StateMachine] to change to [parameter new_state]. This parameter
## takes a [GDScript] object, assuming it's a script that inherets [State],
## otherwise it returns an error.
func change_state(new_state: GDScript) -> void:
	var state := state_machine.get_state(new_state)
	if is_instance_valid(state):
		state_machine.state = state
