class_name State
extends Node
## Base class for Actor States.
## [br]
## [b]TODO:[/b] Decouple this away from my actor system.
## @experimental: When the inspector plugin progresses, I plan on moving this
## away from extending a node, and instead being a resource.

## The [Actor] that the state is affecting.
@onready var actor: Actor:
	get():
		if not actor:
			if state_machine:
				actor = state_machine.actor
		assert(actor, "State failed to set actor!")
		return actor

## The [StateMachine] that is handling the [State].
@onready var state_machine: StateMachine:
	get():
		if not state_machine:
			state_machine = get_parent() as StateMachine
		assert(state_machine, "Failed to get StateMachine!")
		return state_machine

## The [AnimationTree] paired with the [Actor]. Also see: [member actor].
@onready var anim_tree: AnimationTree:
	get():
		assert(actor, "Trying to get anim_tree, but no actor is assigned.")
		if actor:
			return actor.anim_tree
		return null
	set(v):
		return

## The [AnimationNodeStateMachinePlayback] (what a mouthful!) that is paired
## with [member anim_tree] and [member actor].
@onready var anim_playback: AnimationNodeStateMachinePlayback:
	get():
		if anim_tree:
			return anim_tree["parameters/playback"]
		assert(anim_tree, "Can't access animation playback because
				no animation tree exists!")
		return null
	set(v):
		return


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
	return state_machine.state if state_machine else null


## Returns a [bool] if this state is the current state being processed by the
## [StateMachine].
func is_current_state() -> bool:
	return current_state() == self


## Request the [StateMachine] to change to [parameter new_state]. This parameter
## takes a [GDScript] object, assuming it's a script that inherets [State],
## otherwise it returns an error.
func change_state(new_state: GDScript) -> void:
	var state := state_machine.get_state(new_state)
	if actor and state:
		state_machine.state = state
