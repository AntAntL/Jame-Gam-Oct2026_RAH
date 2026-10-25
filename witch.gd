extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer
@onready var area: Area2D = $Area2D
@onready var ap: AnimationPlayer = $MixingAnimation/AnimationPlayer

var alert_label: Label
var witch_looking: bool = false
var suspicion: float = 0.0 # 0.0 to 5.0 (permanent, never decreases)
const MAX_SUSPICION: float = 5.0
const BASE_DETECTION_RATE: float = 0.4
var floor_alert_timer: float = 0.0
var game_over_triggered: bool = false

func _ready() -> void:
	add_to_group("witch")
	
	alert_label = Label.new()
	alert_label.name = "AlertLabel"
	alert_label.text = "!"
	alert_label.visible = false
	alert_label.position = Vector2(-8, -60)
	alert_label.add_theme_font_size_override("font_size", 30)
	alert_label.modulate = Color(1.0, 0.15, 0.15, 1.0)
	add_child(alert_label)
	ap.play("Mixing")

func _physics_process(delta: float) -> void:
	if game_over_triggered:
		return
	var item_spotted = false
	var highest_risk: float = 0.0
	var spotted_item_type = ""
	
	if floor_alert_timer > 0.0:
		floor_alert_timer -= delta
		if floor_alert_timer <= 0.0 and alert_label:
			alert_label.visible = false
	
	var bodies = area.get_overlapping_bodies()
	for body in bodies:
		if (body.is_in_group("item") or body.is_in_group("player")) and !body.is_in_group("inside_cauldron"):
			var cur_item = ""
			if body.is_in_group("player"):
				if body.get("held_item_texture") != null:
					cur_item = str(body.get("held_item_name"))
			else:
				cur_item = str(body.get("item_name"))
			
			if cur_item != "":
				item_spotted = true
				var risk = 1.0
				if cur_item == "itemc":
					risk = 3.5
				elif cur_item == "itema":
					risk = 0.5
				elif cur_item == "itemb":
					risk = 1.0
				
				if risk > highest_risk:
					highest_risk = risk
					spotted_item_type = cur_item
	
	if item_spotted:
		suspicion = min(suspicion + delta * BASE_DETECTION_RATE * highest_risk, MAX_SUSPICION)
		if alert_label:
			alert_label.visible = true
			if suspicion >= MAX_SUSPICION:
				game_over_triggered = true
				alert_label.text = "I SEE YOU"
				alert_label.modulate = Color(1.0, 0.0, 0.0, 1.0)
			elif spotted_item_type == "itemc":
				alert_label.text = "AAAAAAAAAAAAAAAAAA"
				alert_label.modulate = Color(1.0, 0.0, 0.0, 1.0)
			else:
				alert_label.text = "what????"
				alert_label.modulate = Color(1.0, 0.3, 0.1, 1.0)
	else:
		if floor_alert_timer <= 0.0 and alert_label:
			alert_label.visible = false
	
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("set_suspicion"):
		hud.set_suspicion(suspicion, item_spotted)

func alert_floor_crash(item_pos: Vector2, _item_name: String) -> void:
	# Immediately turn witch toward the fallen item
	witch_looking = (item_pos.x < global_position.x)
	sprite.flip_h = witch_looking
	area.scale.x = -1.0 if witch_looking else 1.0
	timer.start(randf_range(3.5, 5.0))
	
	# Hop in shock
	var orig_y = position.y
	var tw = create_tween()
	tw.tween_property(self, "position:y", orig_y - 24.0, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "position:y", orig_y, 0.15).set_trans(Tween.TRANS_BOUNCE)
	
	# Shock alert
	floor_alert_timer = 2.2
	if alert_label:
		alert_label.visible = true
		alert_label.text = "?!?!?!?!?!?!?!"
		alert_label.modulate = Color(1.0, 0.1, 0.1, 1.0)
	
	# Big sus
	suspicion = min(suspicion + 1.6, MAX_SUSPICION)
	if suspicion >= MAX_SUSPICION:
		game_over_triggered = true
		if alert_label:
			alert_label.text = "i see"
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("set_suspicion"):
		hud.set_suspicion(suspicion, true)

func _on_timer_timeout() -> void:
	witch_looking = !witch_looking
	sprite.flip_h = witch_looking
	
	# Flip vision cone Area2D to match witch direction
	area.scale.x = -1.0 if witch_looking else 1.0
	
	timer.wait_time = randf_range(2.0, 4.5)
	
