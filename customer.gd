extends CharacterBody2D

signal customer_finished

enum State { WALKING_IN, AT_COUNTER, WALKING_OUT }

var current_state: State = State.WALKING_IN
var target_x: float = 540.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const TINTS = [
	Color(0.5, 0.8, 1.0),
	Color(1.0, 0.6, 0.6),
	Color(0.6, 1.0, 0.6),
	Color(1.0, 0.9, 0.4),
	Color(0.9, 0.6, 1.0),
	Color(1.0, 0.7, 0.4)
]

func _ready() -> void:
	if sprite:
		sprite.modulate = TINTS.pick_random()

func _physics_process(_delta: float) -> void:
	match current_state:
		State.WALKING_IN:
			velocity.x = 110.0
			move_and_slide()
			if global_position.x >= target_x:
				velocity.x = 0
				arrive_at_counter()
				
		State.WALKING_OUT:
			velocity.x = -135.0
			move_and_slide()
			if global_position.x < -60.0:
				customer_finished.emit()
				queue_free()

func arrive_at_counter() -> void:
	current_state = State.AT_COUNTER
	
	# Wait brief moment at counter while purchasing
	sprite.pause()
	await get_tree().create_timer(1.8).timeout
	serve_potion()

func serve_potion() -> void:
	# Fetch ingredients from cauldron
	var cauldron = get_tree().get_first_node_in_group("cauldron")
	var ingredients: Array[String] = []
	if cauldron and cauldron.has_method("get_and_clear_ingredients"):
		ingredients = cauldron.get_and_clear_ingredients()
	
	var contamination_score: int = 0
	var loss: int = 0
	
	for item in ingredients:
		var lower_item = item.to_lower()
		if lower_item == "itemc" or lower_item.contains("tri"):
			contamination_score += 8
			loss += 140
		elif lower_item == "itemb" or lower_item.contains("vial"):
			contamination_score += 3
			loss += 45
		else:
			contamination_score += 1
			loss += 15
	
	# Star rating based on contamination (8 pts is 1 star)
	var rating: int = 5
	if contamination_score == 0:
		rating = 5
		loss = 0
	elif contamination_score <= 4:
		rating = 4
	elif contamination_score <= 8:
		rating = 3
	elif contamination_score < 15:
		rating = 2
	else:
		rating = 1
	
	# Push notification and loss to HUD
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		if hud.has_method("add_profit_lost") and loss > 0:
			hud.add_profit_lost(loss)
		if hud.has_method("show_review"):
			hud.show_review(rating, loss)
	
	# Wait brief moment after purchase, then leave
	await get_tree().create_timer(1.2).timeout
	leave_shop()

func leave_shop() -> void:
	sprite.play()
	current_state = State.WALKING_OUT
	if sprite:
		sprite.flip_h = true
