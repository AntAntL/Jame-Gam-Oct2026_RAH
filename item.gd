extends RigidBody2D

const TrickPopup = preload("res://trick_popup.gd")

var item_name: String = "item"
var item_texture: Texture2D = null

# Trick shot metrics
var is_jump_shot: bool = false
var bounce_count: int = 0
var air_time: float = 0.0
var passed_over_witch: bool = false
var has_touched_floor: bool = false
var is_in_flight: bool = true
var has_alerted_fall: bool = false

# Motion trail
var trail_line: Line2D
var trail_points: Array[Vector2] = []
const MAX_TRAIL_POINTS: int = 14

func _ready() -> void:
	input_pickable = true
	body_entered.connect(_on_body_entered)
	
	if item_texture == null and has_node("Sprite2D"):
		var spr: Sprite2D = $Sprite2D
		if spr.texture and spr.texture.resource_path != "res://icon.svg":
			item_texture = spr.texture
	
	# Setup glowing motion trail
	trail_line = Line2D.new()
	trail_line.top_level = true
	trail_line.width = 6.0
	trail_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	trail_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	trail_line.joint_mode = Line2D.LINE_JOINT_ROUND
	
	var grad = Gradient.new()
	grad.set_color(0, Color(1.0, 0.9, 0.3, 0.9))
	grad.set_color(1, Color(1.0, 0.3, 0.1, 0.0))
	trail_line.gradient = grad
	add_child(trail_line)

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

func _physics_process(delta: float) -> void:
	if is_in_group("inside_cauldron"):
		if trail_line and trail_line.visible:
			trail_line.visible = false
		return
	
	if is_in_flight:
		air_time += delta
		
		# Check if flew over the witch (witch is at X ~639)
		if abs(global_position.x - 639.0) < 65.0 and global_position.y < 350.0:
			if not passed_over_witch:
				passed_over_witch = true
				TrickPopup.spawn(get_parent(), global_position, "over omg", Color(0.8, 0.4, 1.0))
		
		# Update motion trail
		if trail_line:
			trail_points.push_front(global_position)
			if trail_points.size() > MAX_TRAIL_POINTS:
				trail_points.pop_back()
			
			var pts = PackedVector2Array()
			for p in trail_points:
				pts.append(p)
			trail_line.points = pts
		
		# Check if settled on the ground
		if linear_velocity.length() < 15.0 and global_position.y > 440.0 and air_time > 0.4:
			is_in_flight = false
			if trail_line:
				trail_line.visible = false
			var cam = get_tree().get_first_node_in_group("main_camera")
			if cam and cam.has_method("return_to_player"):
				cam.return_to_player()
				
			# Fail text
			TrickPopup.spawn(get_parent(), global_position, "FAIL!!!!!!!!", Color(0.816, 0.224, 0.0, 1.0))
			trigger_fall_alert()
	
	# Proximity pickup: if player is close (< 80px) and presses E
	var player = get_tree().get_first_node_in_group("player")
	if player and global_position.distance_to(player.global_position) < 80.0:
		if Input.is_key_pressed(KEY_E):
			try_pickup()

func _on_body_entered(body: Node) -> void:
	if is_in_group("inside_cauldron"):
		return
	if body.is_in_group("player"):
		return
	
	# Wall / Ceiling / Surface ricochet
	bounce_count += 1
	var cam = get_tree().get_first_node_in_group("main_camera")
	if cam and cam.has_method("add_shake"):
		cam.add_shake(0.2)
		
	# Check if like there is enough velocity cuz like then there will be 12 billion bounces
	if (linear_velocity.length() < 100):
		return
	
	# Text on bounce
	var bounce_text = "BOUNCE!"
	if bounce_count == 2:
		bounce_text = "DOUBLE BOUNCE!"
	elif bounce_count >= 3:
		bounce_text = "AAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	
	TrickPopup.spawn(get_parent(), global_position, bounce_text, Color(1.0, 0.65, 0.1))
	
	if global_position.y > 450.0:
		has_touched_floor = true
		trigger_fall_alert()

func trigger_fall_alert() -> void:
	if has_alerted_fall or is_in_group("inside_cauldron"):
		return
	has_alerted_fall = true
	
	var witch = get_tree().get_first_node_in_group("witch")
	if witch and witch.has_method("alert_floor_crash"):
		witch.alert_floor_crash(global_position, item_name)
	
	# Text saying the witch saw it
	TrickPopup.spawn(get_parent(), global_position + Vector2(0, -45), "witch saw :(", Color(1.0, 0.18, 0.18))
	
	var cam = get_tree().get_first_node_in_group("main_camera")
	if cam and cam.has_method("add_shake"):
		cam.add_shake(0.42)

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_in_group("inside_cauldron"):
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
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
		
		var cam = get_tree().get_first_node_in_group("main_camera")
		if cam and cam.has_method("return_to_player"):
			cam.return_to_player()
		
		if trail_line:
			trail_line.queue_free()
		queue_free()

func _mouse_enter() -> void:
	if !is_in_group("inside_cauldron"):
		modulate = Color(1.3, 1.3, 1.3, 1.0)

func _mouse_exit() -> void:
	modulate = Color(1.0, 1.0, 1.0, 1.0)

func get_trick_data() -> Dictionary:
	return {
		"is_jump_shot": is_jump_shot,
		"bounce_count": bounce_count,
		"air_time": air_time,
		"passed_over_witch": passed_over_witch,
		"is_swish": not has_touched_floor and bounce_count == 0
	}
