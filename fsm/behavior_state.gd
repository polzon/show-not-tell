class_name State
extends Node
## Base class for Actor States.
## [br]
## TODO: Decouple this away from my actor system.

signal state_start

signal state_end

@onready var actor: Actor:
	get():
		if not actor:
			if state_machine:
				actor = state_machine.actor
		assert(actor, "State failed to set actor!")
		return actor

@onready var state_machine: StateMachine:
	get():
		if not state_machine:
			state_machine = get_parent() as StateMachine
		assert(state_machine, "Failed to get StateMachine!")
		return state_machine

@onready var anim_tree: AnimationTree:
	get():
		assert(actor, "Trying to get anim_tree, but no actor is assigned.")
		if actor:
			return actor.anim_tree
		return null
	set(v):
		return

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
	state_start.emit()


func _on_state_end() -> void:
	state_end.emit()


## Method that is called from [StateMachine] and is only updated
## when the [State] is the current state.
func _update_state(_delta: float) -> void:
	pass


func current_state() -> State:
	return state_machine.state if state_machine else null


func is_current_state() -> bool:
	return current_state() == self


func change_state(new_state: GDScript) -> void:
	var state := state_machine.get_state(new_state)
	if actor and state:
		state_machine.state = state


## Temp debug function to draw a tile rect at the mouse position.
func _debug_show_mouse_tile() -> void:
	var mouse_global_pos := actor.get_global_mouse_position()
	var mouse_tile_pos := DebugGrid.global_pos_to_tile_coord(mouse_global_pos)
	var mouse_tile_rect := DebugGrid.get_tile_rect(mouse_tile_pos)

	var does_intersect := mouse_tile_rect.intersects(Rect2(
			mouse_global_pos.x,
			mouse_global_pos.y,
			0,
			0))

	DebugUtil.draw_debug_line(actor.position, mouse_global_pos)
	DebugUtil.draw_debug_rect(mouse_tile_rect)
	DebugUtil.draw_debug_circle(
			mouse_global_pos,
			2.0,
			Color.GREEN if does_intersect else Color.RED)
	_debug_draw_selected_actor(actor)


## Temp debug function to draw a bounding box around an actor.
static func _debug_draw_selected_actor(target: Actor) -> void:
	var _mouse_global_pos := target.get_global_mouse_position()

	var col := target.find_child("CollisionShape2D") as CollisionShape2D
	if not col:
		return

	var col_bounds := col.shape.get_rect()
	col_bounds.position += target.position
	DebugUtil.draw_debug_rect(col_bounds)
