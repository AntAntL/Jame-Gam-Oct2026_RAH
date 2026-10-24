extends Area2D

const TrickPopup = preload("res://trick_popup.gd")

signal ingredient_added(item_name: String)

var ingredients: Array[String] = []

func _ready() -> void:
	add_to_group("cauldron")

func _on_body_entered(body: Node2D) -> void:
	if (!body.is_in_group("item")):
		return
	
	body.add_to_group("inside_cauldron")
	var item_name = "item"
	if "item_name" in body and body.item_name != "":
		item_name = body.item_name
	
	# Extract trick shot metrics
	var trick_data = {}
	if body.has_method("get_trick_data"):
		trick_data = body.get_trick_data()
	
	var bonus_loss: int = 0
	var trick_titles: Array[String] = []
	
	var bounces: int = int(trick_data.get("bounce_count", 0))
	if bounces > 0:
		bonus_loss += bounces * 35
		trick_titles.append("bounce x" + str(bounces))
	
	if bool(trick_data.get("is_jump_shot", false)):
		bonus_loss += 40
		trick_titles.append("jump shot wow")
		
	if bool(trick_data.get("passed_over_witch", false)):
		bonus_loss += 60
		trick_titles.append("over the witch")
		
	if bool(trick_data.get("is_swish", false)):
		bonus_loss += 50
		trick_titles.append("oooooo")
	
	# Score bonus & trigger popups
	var world_root = get_tree().current_scene
	if bonus_loss > 0:
		var hud = get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("add_profit_lost"):
			hud.add_profit_lost(bonus_loss)
		
		var title_str = ", ".join(trick_titles) + " crazy\n+$" + str(bonus_loss)
		TrickPopup.spawn(world_root, global_position + Vector2(0, -75), title_str, Color(1.0, 0.9, 0.1))
	else:
		TrickPopup.spawn(world_root, global_position + Vector2(0, -55), "dunked", Color(0.4, 1.0, 0.5))
	
	# Screen shake
	var cam = get_tree().get_first_node_in_group("main_camera")
	if cam:
		cam.add_shake(0.6 if bonus_loss > 0 else 0.3)
		# Delay camera return so player watches the landing
		get_tree().create_timer(0.45).timeout.connect(cam.return_to_player)
	
	# Hitstop / Micro-pause for juicy impact
	if bonus_loss > 0:
		Engine.time_scale = 0.15
		get_tree().create_timer(0.08, true, false, true).timeout.connect(func(): Engine.time_scale = 1.0)
	
	# Cauldron Squash & Stretch bounce animation
	var parent_node = get_parent() as Node2D
	if parent_node:
		var orig_scale = parent_node.scale
		var tw = create_tween()
		tw.tween_property(parent_node, "scale", orig_scale * Vector2(1.3, 0.7), 0.08)
		tw.tween_property(parent_node, "scale", orig_scale * Vector2(0.85, 1.25), 0.12)
		tw.tween_property(parent_node, "scale", orig_scale, 0.15)
	
	ingredients.append(item_name)
	ingredient_added.emit(item_name)
	print("Cauldron accepted ingredient: ", item_name, " (Total in brew: ", ingredients.size(), ")")
	
	# Dissolve item smoothly into brew
	if body is RigidBody2D:
		body.freeze = true
	var tween = create_tween()
	tween.parallel().tween_property(body, "scale", Vector2.ZERO, 0.25)
	tween.parallel().tween_property(body, "modulate:a", 0.0, 0.25)
	tween.tween_callback(body.queue_free)

func get_and_clear_ingredients() -> Array[String]:
	var current = ingredients.duplicate()
	ingredients.clear()
	return current

func get_ingredient_count() -> int:
	return ingredients.size()
