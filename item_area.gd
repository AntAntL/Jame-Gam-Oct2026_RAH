extends Area2D

const TrickPopup = preload("res://trick_popup.gd")

@onready var WaterSplash: AnimatedSprite2D = $"../WaterSplash"
@onready var WaterSplashTimer: Timer = $"../WaterSplash/Timer"
@onready var WaterCauld: Sprite2D = $"../WaterCauld"
@onready var WaterCauldTimer: Timer = $"../WaterCauldTimer"

signal ingredient_added(item_name: String)

var ingredients: Array[String] = []
var cauldron_base_scale: Vector2 = Vector2.ONE
var cauldron_tween: Tween = null

func _ready() -> void:
	add_to_group("cauldron")
	var parent_node = get_parent() as Node2D
	if parent_node:
		cauldron_base_scale = parent_node.scale

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
	
	# Play water splash SFX
	if body.has_method("play_splash_sfx"):
		body.play_splash_sfx()
		
	# Splash water thingy
	WaterSplash.visible = true
	WaterSplashTimer.start()
	WaterSplash.play()
	
	var bonus_loss: int = 0
	var trick_titles: Array[String] = []
	
	var bounces: int = int(trick_data.get("bounce_count", 0))
	if bounces > 0:
		bonus_loss += bounces * 35
		trick_titles.append("bounce x" + str(bounces))
	
	if bool(trick_data.get("is_jump_shot", false)):
		bonus_loss += 40
		trick_titles.append("jump shot")
		
	if bool(trick_data.get("passed_over_witch", false)):
		bonus_loss += 60
		trick_titles.append("over?")
		
	if bool(trick_data.get("is_swish", false)):
		bonus_loss += 50
		trick_titles.append("thrown")
	
	# Popup
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
		if bonus_loss > 0:
			cam.add_shake(0.2)
		get_tree().create_timer(0.35).timeout.connect(cam.return_to_player)
	
	# Thing
	if bonus_loss > 0:
		Engine.time_scale = 0.3
		get_tree().create_timer(0.05, true, false, true).timeout.connect(func(): Engine.time_scale = 1.0)
	
	# Animation
	var parent_node = get_parent() as Node2D
	if parent_node:
		if cauldron_tween and cauldron_tween.is_valid():
			cauldron_tween.kill()
		cauldron_tween = create_tween()
		cauldron_tween.tween_property(parent_node, "scale", cauldron_base_scale * Vector2(1.05, 0.95), 0.07).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		cauldron_tween.tween_property(parent_node, "scale", cauldron_base_scale, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
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


func _on_timer_timeout() -> void:
	WaterSplash.visible = false


func _on_water_cauld_timer_timeout() -> void:
	var redden_speed = 0.2 * get_ingredient_count()
	WaterCauld.modulate.g = move_toward(modulate.g, 0.0, redden_speed)
	WaterCauld.modulate.b = move_toward(modulate.b, 0.0, redden_speed)
