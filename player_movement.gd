extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var THROWABLE = preload("res://item.tscn")
@onready var item_holding: Sprite2D = $ItemHolding

var held_item_name: String = ""
var held_item_texture: Texture2D = null

func _ready() -> void:
	add_to_group("player")
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
		if item_name == "itemc":
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

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	if Input.is_action_just_pressed("throw"):
		throw_item()

func throw_item() -> void:
	# Only throw if currently holding an item
	if held_item_texture == null:
		return

	var item_instance = THROWABLE.instantiate()
	
	# Determine facing direction
	var throw_direction = 1.0 if velocity.x >= 0 else -1.0
	var speed = 500.0
	var upward_arc = -200.0
	
	get_parent().add_child(item_instance)
	item_instance.global_position = global_position + Vector2(throw_direction * 20, -100)
	item_instance.linear_velocity = Vector2(throw_direction * speed, upward_arc)

	if item_instance.has_method("set_item"):
		item_instance.set_item(held_item_name, held_item_texture)

	# Held item disappears from player
	clear_held_item()
