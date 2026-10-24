extends RigidBody2D

var item_name: String = "item"
var item_texture: Texture2D = null

func _ready() -> void:
	input_pickable = true
	# Capture texture from sprite if not already set
	if item_texture == null and has_node("Sprite2D"):
		var spr: Sprite2D = $Sprite2D
		if spr.texture and spr.texture.resource_path != "res://icon.svg":
			item_texture = spr.texture

func set_item(p_name: String, p_texture: Texture2D) -> void:
	item_name = p_name
	item_texture = p_texture
	if has_node("Sprite2D") and p_texture != null:
		var spr: Sprite2D = $Sprite2D
		spr.texture = p_texture
		if p_name == "itemc":
			spr.scale = Vector2(0.26, 0.26)
		elif p_name == "itema":
			spr.scale = Vector2(0.16, 0.16)
		else:
			spr.scale = Vector2(0.195, 0.195)

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_in_group("inside_cauldron"):
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		try_pickup()

func _physics_process(_delta: float) -> void:
	if is_in_group("inside_cauldron"):
		return
	
	# Proximity pickup: if player is close (< 80px) and presses E
	var player = get_tree().get_first_node_in_group("player")
	if player and global_position.distance_to(player.global_position) < 80.0:
		if Input.is_key_pressed(KEY_E):
			try_pickup()

func try_pickup() -> void:
	if is_in_group("inside_cauldron"):
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_held_item"):
		var tex = item_texture
		if tex == null and has_node("Sprite2D"):
			tex = $Sprite2D.texture
		player.set_held_item(item_name, tex)
		queue_free()

func _mouse_enter() -> void:
	if !is_in_group("inside_cauldron"):
		modulate = Color(1.3, 1.3, 1.3, 1.0)

func _mouse_exit() -> void:
	modulate = Color(1.0, 1.0, 1.0, 1.0)
