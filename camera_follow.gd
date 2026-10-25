extends Camera2D

var target_node: Node2D = null
var default_target: Node2D = null
var trauma: float = 0.0
var max_shake: float = 24.0
var default_zoom: Vector2 = Vector2(1.0, 1.0)
var target_zoom: Vector2 = Vector2(1.0, 1.0)

func _ready() -> void:
	add_to_group("main_camera")
	top_level = true
	default_target = get_parent() as Node2D
	target_node = default_target
	if default_target:
		global_position = default_target.global_position

func track_item(item: Node2D) -> void:
	target_node = item
	target_zoom = Vector2(1.18, 1.18)

func return_to_player() -> void:
	target_node = default_target
	target_zoom = default_zoom

func add_shake(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)

func _process(delta: float) -> void:
	# If tracking an item that got destroyed or finished, return smoothly to player
	if target_node == null or not is_instance_valid(target_node):
		return_to_player()
	
	if target_node and is_instance_valid(target_node):
		var target_pos = target_node.global_position
		# Smooth camera follow
		global_position = global_position.lerp(target_pos + Vector2(0, -50), delta * 8.5)
	
	# Smooth zoom
	zoom = zoom.lerp(target_zoom, delta * 5.0)
	
	# Screen shake
	if trauma > 0.0:
		trauma = max(trauma - delta * 2.8, 0.0)
		var shake = trauma * trauma * max_shake
		offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake
	else:
		offset = Vector2.ZERO
