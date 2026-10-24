extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer
@onready var area: Area2D = $Area2D

var alert_label: Label
var witch_looking: bool = false
var suspicion: float = 0.0 # 0.0 to 5.0 (permanent, never decreases)
const MAX_SUSPICION: float = 5.0
const BASE_DETECTION_RATE: float = 0.4

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

func _physics_process(delta: float) -> void:
	var item_spotted = false
	var highest_risk: float = 0.0
	var spotted_item_type = ""
	
	var bodies = area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("item") and !body.is_in_group("inside_cauldron"):
			var cur_item = ""
			if body.is_in_group("player"):
				if body.get("held_item_texture") != null:
					cur_item = str(body.get("held_item_name"))
			else:
				cur_item = str(body.get("item_name"))
			
			if cur_item != "":
				item_spotted = true
				# Item C is insanely risky (3.5x speed!), A is small (0.5x), B is standard (1.0x)
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
			if spotted_item_type == "itemc":
				alert_label.text = "!!!"
				alert_label.modulate = Color(1.0, 0.0, 0.0, 1.0)
			else:
				alert_label.text = "!"
				alert_label.modulate = Color(1.0, 0.3, 0.1, 1.0)
	else:
		# Permanent: never decays
		if alert_label:
			alert_label.visible = false
	
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("set_suspicion"):
		hud.set_suspicion(suspicion, item_spotted)

func _on_timer_timeout() -> void:
	witch_looking = !witch_looking
	sprite.flip_h = witch_looking
	
	# Flip vision cone Area2D to match witch direction
	area.scale.x = -1.0 if witch_looking else 1.0
	
	timer.wait_time = randf_range(2.0, 4.5)
