@tool
class_name ShowNotTellPlugin
extends EditorPlugin

## The [PackedScene] of the editor node that is added to the Editor.
static var gridmap_dock: Control:
	get():
		if not gridmap_dock:
			var behavior_graph := preload(BehaviorGraph.GRAPH_TSCN_UID)
			if behavior_graph and behavior_graph.can_instantiate():
				gridmap_dock = behavior_graph.instantiate()
		return gridmap_dock

## Name that will show up inside the editor.
const EDITOR_CONTROL_NAME := "Behavior Graph"

# Behavior editor dock plugin.
const DOCK_SETTING_NAME := "addons/show_not_tell/enable_dock"
const DOCK_SETTING_DEFAULT := true

var _was_dock_added: bool = false


func _enter_tree() -> void:
	_setup_dock()
	ProjectSettings.settings_changed.connect(_on_project_settings_changed)


func _exit_tree() -> void:
	if _was_dock_added:
		_remove_dock()


func _setup_dock() -> void:
	if not ProjectSettings.has_setting(DOCK_SETTING_NAME):
		ProjectSettings.set_setting(DOCK_SETTING_NAME, DOCK_SETTING_DEFAULT)
	ProjectSettings.set_initial_value(DOCK_SETTING_NAME, DOCK_SETTING_DEFAULT)

	if _is_dock_enabled():
		_create_dock()


func _is_dock_enabled() -> bool:
	return ProjectSettings.get_setting(DOCK_SETTING_NAME, DOCK_SETTING_DEFAULT)


func _create_dock() -> void:
	assert(not _was_dock_added)
	# TODO: Only show while a Node is selected of the type StateMachine
	add_control_to_bottom_panel(gridmap_dock, EDITOR_CONTROL_NAME)
	_was_dock_added = true


func _remove_dock() -> void:
	assert(_was_dock_added)
	remove_control_from_bottom_panel(gridmap_dock)
	gridmap_dock.queue_free()
	_was_dock_added = false


func _on_project_settings_changed() -> void:
	if not _is_dock_enabled() and _was_dock_added:
		_remove_dock()
	elif _is_dock_enabled() and not _was_dock_added:
		_create_dock()
