extends Camera2D

# Built-in limit controls (configured directly in the Inspector)
@export_group("Limits")
@export var limits_enabled: bool = true
@export var level_limit_left: int = -10000
@export var level_limit_top: int = -10000
@export var level_limit_right: int = 10000
@export var level_limit_bottom: int = 10000

var target_node: Node2D = null
var default_target: Node2D = null
var trauma: float = 0.0
var max_shake: float = 24.0
var default_zoom: Vector2 = Vector2(1.05, 1.05)
var target_zoom: Vector2 = Vector2(1.0, 1.0)

func _ready() -> void:
	add_to_group("main_camera")
	top_level = true
	default_target = get_parent() as Node2D
	target_node = default_target
	
	_apply_limits()
	
	if default_target:
		global_position = default_target.global_position

func _apply_limits() -> void:
	if limits_enabled:
		limit_left = level_limit_left
		limit_top = level_limit_top
		limit_right = level_limit_right
		limit_bottom = level_limit_bottom
	else:
		# Godot's default virtual unbounded limits
		limit_left = -10000000
		limit_top = -10000000
		limit_right = 10000000
		limit_bottom = 10000000

func track_item(item: Node2D) -> void:
	target_node = item
	target_zoom = Vector2(1.18, 1.18)

func return_to_player() -> void:
	target_node = default_target
	target_zoom = default_zoom

func add_shake(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)

func _process(delta: float) -> void:
	if target_node == null or not is_instance_valid(target_node):
		return_to_player()

	# Smooth zoom
	zoom = zoom.lerp(target_zoom, delta * 5.0)

	# Smooth follow (Godot's built-in limits automatically stop the visible frame)
	if target_node and is_instance_valid(target_node):
		var target_pos: Vector2 = target_node.global_position + Vector2(0, -50)
		global_position = global_position.lerp(target_pos, delta * 8.5)

	# Screen shake
	if trauma > 0.0:
		trauma = max(trauma - delta * 2.8, 0.0)
		var shake: float = trauma * trauma * max_shake
		offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake
	else:
		offset = Vector2.ZERO
