extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var THROWABLE = preload("res://item.tscn")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	if Input.is_action_just_pressed("throw"):
		throw_item()

func throw_item() -> void:
	var item_instance = THROWABLE.instantiate()
	
	# Determine facing direction
	var throw_direction = 1.0 if velocity.x >= 0 else -1.0
	var speed = 500.0
	var upward_arc = -200.0
	
	# 1. Add to scene tree first
	get_parent().add_child(item_instance)
	
	# 2. Position it
	item_instance.global_position = global_position + Vector2(throw_direction * 20, -100)
	
	# 3. Apply physics velocity
	item_instance.linear_velocity = Vector2(throw_direction * speed, upward_arc)
