@tool
class_name ShowNotTellPlugin
extends EditorPlugin

## The [PackedScene] of the editor node that actually gets added to
## the editor UI.
static var gridmap_dock: Control:
	get():
		if not gridmap_dock:
			gridmap_dock = preload(
					BehaviorGraph.GRAPH_TSCN_UID).instantiate()
		return gridmap_dock

## Name that will show up inside the editor.
const EDITOR_CONTROL_NAME := "Behavior Graph"

var test: EditorExportPlugin

## If this should be enabled as an editor autoload.
const ENABLE_AUTOLOAD: bool = true

## Internal check on if we added the autoload, since there's no way to check
## otherwise.
var _has_added_autoload: bool = false


func _enter_tree() -> void:
	# TODO: Only show while a Node is selected of the type StateMachine
	add_control_to_bottom_panel(gridmap_dock, EDITOR_CONTROL_NAME)


func _exit_tree() -> void:
	remove_control_from_bottom_panel(gridmap_dock)
	gridmap_dock.queue_free()


func _enable_plugin() -> void:
	if ENABLE_AUTOLOAD:
		add_autoload_singleton("Behavior", BehaviorSingleton.BEHAVIOR_GD_PATH)
		_has_added_autoload = true


func _remove_plugin() -> void:
	if _has_added_autoload:
		remove_autoload_singleton("Behavior")
		_has_added_autoload = false


func _get_plugin_icon() -> Texture2D:
	return preload("res://addons/show_not_tell/plugin_icon.svg")


## Checks if node exists in tree. If not found, then it adds.
static func _add_child_if_possible(node: EditorPlugin, tree: SceneTree) -> bool:
	for child: Node in tree:
		# If exists in tree, abort.
		if child == node:
			return false
	tree.root.add_child(node)
	return true
