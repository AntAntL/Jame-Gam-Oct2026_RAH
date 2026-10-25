extends CharacterBody2D

const TrickPopup = preload("res://trick_popup.gd")

const SPEED = 300.0
const JUMP_VELOCITY = -600.0

const MIN_POWER: float = 320.0
const MAX_POWER: float = 980.0
const MAX_CHARGE_TIME: float = 1.0

@onready var THROWABLE = preload("res://item.tscn")
@onready var item_holding: Sprite2D = $ItemHolding
@onready var sprite: Sprite2D = $Sprite2D

var held_item_name: String = ""
var held_item_texture: Texture2D = null

# Arc throwing state
var is_charging: bool = false
var charge_time: float = 0.0
var charging_with_mouse: bool = false
var charging_with_action: bool = false

var trajectory_line: Line2D
var power_bar: ProgressBar
var power_bar_fill: StyleBoxFlat

func _ready() -> void:
	add_to_group("player")
	
	# Setup Trajectory Line
	trajectory_line = Line2D.new()
	trajectory_line.name = "TrajectoryLine"
	trajectory_line.width = 3.5
	trajectory_line.default_color = Color(1.0, 0.85, 0.25, 0.85)
	trajectory_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	trajectory_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	trajectory_line.joint_mode = Line2D.LINE_JOINT_ROUND
	
	var line_grad = Gradient.new()
	line_grad.set_color(0, Color(1.0, 0.9, 0.3, 0.9))
	line_grad.set_color(1, Color(1.0, 0.4, 0.1, 0.25))
	trajectory_line.gradient = line_grad
	trajectory_line.visible = false
	add_child(trajectory_line)
	
	# Setup Power Bar
	power_bar = ProgressBar.new()
	power_bar.name = "PowerBar"
	power_bar.size = Vector2(54, 8)
	power_bar.position = Vector2(-27, -112)
	power_bar.show_percentage = false
	power_bar.visible = false
	
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	bg_style.set_corner_radius_all(3)
	
	power_bar_fill = StyleBoxFlat.new()
	power_bar_fill.bg_color = Color(0.2, 0.9, 0.3, 0.9)
	power_bar_fill.set_corner_radius_all(3)
	
	power_bar.add_theme_stylebox_override("background", bg_style)
	power_bar.add_theme_stylebox_override("fill", power_bar_fill)
	add_child(power_bar)

	# Start with item if already set in the editor, or hide if none
	if item_holding and item_holding.texture:
		held_item_name = "itema"
		held_item_texture = item_holding.texture
		item_holding.visible = true
		add_to_group("item")
	elif item_holding:
		item_holding.visible = false
		remove_from_group("item")

func set_held_item(item_name: String, texture: Texture2D) -> void:
	held_item_name = item_name
	held_item_texture = texture
	if item_holding:
		item_holding.texture = texture
		if texture != null and texture.get_width() <= 32:
			item_holding.scale = Vector2(2.6, 2.6)
			item_holding.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		elif item_name == "itemc":
			item_holding.scale = Vector2(0.26, 0.26)
		elif item_name == "itema":
			item_holding.scale = Vector2(0.16, 0.16)
		else:
			item_holding.scale = Vector2(0.195, 0.195)
		item_holding.visible = true
	add_to_group("item")

func clear_held_item() -> void:
	held_item_name = ""
	held_item_texture = null
	if item_holding:
		item_holding.texture = null
		item_holding.visible = false
	remove_from_group("item")
	cancel_charging()

func _unhandled_input(event: InputEvent) -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.get("is_game_over"):
		return
	if held_item_texture == null:
		return
	
	# Support Right Mouse Button hold & release
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed and not is_charging:
			start_charging(true, false)
		elif not event.pressed and is_charging and charging_with_mouse:
			finish_charging_and_throw()

func start_charging(with_mouse: bool, with_action: bool) -> void:
	is_charging = true
	charge_time = 0.0
	charging_with_mouse = with_mouse
	charging_with_action = with_action
	if trajectory_line:
		trajectory_line.visible = true
	if power_bar:
		power_bar.visible = true
		power_bar.value = 0.0

func cancel_charging() -> void:
	is_charging = false
	charging_with_mouse = false
	charging_with_action = false
	charge_time = 0.0
	if trajectory_line:
		trajectory_line.visible = false
	if power_bar:
		power_bar.visible = false

func finish_charging_and_throw() -> void:
	if not is_charging:
		return
	var ratio = clamp(charge_time / MAX_CHARGE_TIME, 0.08, 1.0)
	cancel_charging()
	launch_item(ratio)

func _physics_process(delta: float) -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.get("is_game_over"):
		if is_charging:
			cancel_charging()
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if not is_on_floor():
			velocity += get_gravity() * delta
		move_and_slide()
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	var move_speed = SPEED * 0.6 if is_charging else SPEED
	if direction:
		velocity.x = direction * move_speed
		if not is_charging and sprite:
			sprite.flip_h = (direction < 0)
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)

	move_and_slide()
	
	# Handle keyboard throw action
	if held_item_texture != null:
		if Input.is_action_just_pressed("throw") and not is_charging:
			start_charging(false, true)
		elif Input.is_action_just_released("throw") and is_charging and charging_with_action:
			finish_charging_and_throw()

	# Process charging & update visual arc
	if is_charging:
		charge_time = min(charge_time + delta, MAX_CHARGE_TIME)
		var ratio = clamp(charge_time / MAX_CHARGE_TIME, 0.08, 1.0)
		
		# Face towards mouse while aiming
		var mouse_pos = get_global_mouse_position()
		if sprite:
			sprite.flip_h = (mouse_pos.x < global_position.x)
		
		update_trajectory_arc(ratio)
		update_power_bar(ratio)

func update_power_bar(ratio: float) -> void:
	if not power_bar:
		return
	power_bar.value = ratio * 100.0
	if power_bar_fill:
		if ratio < 0.5:
			power_bar_fill.bg_color = lerp(Color(0.2, 0.9, 0.3), Color(0.95, 0.85, 0.2), ratio * 2.0)
		else:
			power_bar_fill.bg_color = lerp(Color(0.95, 0.85, 0.2), Color(1.0, 0.2, 0.1), (ratio - 0.5) * 2.0)

func update_trajectory_arc(ratio: float) -> void:
	if not trajectory_line:
		return
	
	var throw_origin = global_position + Vector2(0, -70)
	var mouse_pos = get_global_mouse_position()
	var aim_dir = (mouse_pos - throw_origin).normalized()
	var speed = lerp(MIN_POWER, MAX_POWER, ratio)
	var launch_vel = aim_dir * speed
	var grav = get_gravity()
	
	var points: PackedVector2Array = []
	var local_start = Vector2(0, -70)
	points.append(local_start)
	
	var step: float = 0.035
	for i in range(1, 30):
		var t = i * step
		var pt = local_start + launch_vel * t + 0.5 * grav * (t * t)
		points.append(pt)
		if pt.y > 48.0:
			break
	
	trajectory_line.points = points

func launch_item(power_ratio: float) -> void:
	if held_item_texture == null:
		return

	var was_airborne = not is_on_floor()
	var item_instance = THROWABLE.instantiate()
	var throw_origin = global_position + Vector2(0, -70)
	var mouse_pos = get_global_mouse_position()
	var aim_dir = (mouse_pos - throw_origin).normalized()
	
	var speed = lerp(MIN_POWER, MAX_POWER, power_ratio)
	var launch_velocity = aim_dir * speed

	get_parent().add_child(item_instance)
	item_instance.global_position = throw_origin
	item_instance.linear_velocity = launch_velocity
	
	# Spin
	var spin_dir = 1.0 if launch_velocity.x >= 0 else -1.0
	item_instance.angular_velocity = spin_dir * randf_range(5.0, 12.0)

	if item_instance.has_method("set_item"):
		item_instance.set_item(held_item_name, held_item_texture)

	# Jump shot detect
	if was_airborne and "is_jump_shot" in item_instance:
		item_instance.is_jump_shot = true
		TrickPopup.spawn(get_parent(), global_position, "no way jump shot?????", Color(0.3, 0.9, 1.0))
		if item_instance.has_method("add_combo"):
			item_instance.add_combo()
		
	if velocity.distance_to(Vector2(0, 0)) > 2:
		TrickPopup.spawn(get_parent(), global_position, "running start wow", Color(0.0, 0.748, 0.307, 1.0))
		if item_instance.has_method("add_combo"):
			item_instance.add_combo()

	# Lock camera onto the flying projectile
	var cam = get_tree().get_first_node_in_group("main_camera")
	if cam and cam.has_method("track_item"):
		cam.track_item(item_instance)

	# Held item disappears from player
	clear_held_item()
