extends Node2D

@export var customer_scene: PackedScene = preload("res://customer.tscn")
@export var spawn_position: Vector2 = Vector2(-30, 560)

var current_customer: Node = null
var spawn_timer: Timer

func _ready() -> void:
	# Initially wait so player can read tutorial
	await get_tree().create_timer(8).timeout
	
	spawn_timer = Timer.new()
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	
	# Spawn first customer after 2.5 seconds
	spawn_timer.start(2.5)

func _on_spawn_timer_timeout() -> void:
	spawn_customer()

func spawn_customer() -> void:
	if current_customer != null and is_instance_valid(current_customer):
		return
	
	if customer_scene:
		var cust = customer_scene.instantiate()
		cust.global_position = spawn_position
		cust.customer_finished.connect(_on_customer_finished)
		current_customer = cust
		get_parent().add_child(cust)

func _on_customer_finished() -> void:
	current_customer = null
	# Schedule next customer in 3.0 to 5.5 seconds
	spawn_timer.start(randf_range(3.0, 5.5))
