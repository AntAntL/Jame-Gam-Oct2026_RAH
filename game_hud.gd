extends CanvasLayer

const TrickPopup = preload("res://trick_popup.gd")

@onready var profit_label: Label = $TopLeft/MarginContainer/ProfitLabel
@onready var vignette_rect: TextureRect = $VignetteRect

# Review notification elements
@onready var review_panel: PanelContainer = $TopRight/ReviewPanel
@onready var review_stars: Label = $TopRight/ReviewPanel/MarginContainer/VBoxContainer/StarsLabel
@onready var review_loss: Label = $TopRight/ReviewPanel/MarginContainer/VBoxContainer/LossLabel

var total_profit_lost: int = 0
var displayed_profit: int = 0
var profit_roll_tween: Tween = null

var current_suspicion: float = 0.0
var prev_star_count: int = 0
var review_tween: Tween = null
var base_notice_scale: Vector2 = Vector2(4.642, 4.651)

func _ready() -> void:
	add_to_group("hud")
	update_profit_display()
	update_detect_display(0.0)
	
	# Programmatic radial red vignette for screen edges
	var gradient_tex = GradientTexture2D.new()
	var gradient = Gradient.new()
	gradient.set_color(0, Color(0.85, 0.05, 0.05, 0.0))
	gradient.set_color(1, Color(0.85, 0.05, 0.05, 0.85))
	gradient_tex.gradient = gradient
	gradient_tex.fill = GradientTexture2D.FILL_RADIAL
	gradient_tex.fill_from = Vector2(0.5, 0.5)
	gradient_tex.fill_to = Vector2(0.5, 0.0)
	gradient_tex.width = 512
	gradient_tex.height = 384
	vignette_rect.texture = gradient_tex
	vignette_rect.modulate.a = 0.0
	
	if review_panel:
		review_panel.modulate.a = 0.0

func _process(_delta: float) -> void:
	# Danger vibration on NoticeBar when max suspicion (5 stars)
	if current_suspicion >= 5.0:
		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_node("NoticeBar"):
			var p_bar: Label = player.get_node("NoticeBar")
			var shake_offset = Vector2(randf_range(-3.0, 3.0), randf_range(-3.0, 3.0))
			p_bar.position = Vector2(56.0, -312.0) + shake_offset

func add_profit_lost(amount: int) -> void:
	total_profit_lost += amount
	
	# Floating damage indicator in HUD
	if profit_label:
		var float_pos = profit_label.global_position + Vector2(180, 10)
		TrickPopup.spawn(self, float_pos, "-$" + str(amount), Color(0.3, 1.0, 0.4))
	
	# Rolling number counter tween
	if profit_roll_tween and profit_roll_tween.is_valid():
		profit_roll_tween.kill()
	
	profit_roll_tween = create_tween()
	profit_roll_tween.tween_method(
		func(val: int):
			displayed_profit = val
			update_profit_display(),
		displayed_profit,
		total_profit_lost,
		0.55
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	# Scale & rotation punch on profit label
	if profit_label:
		profit_label.pivot_offset = profit_label.size * 0.5
		var t = create_tween()
		t.parallel().tween_property(profit_label, "scale", Vector2(1.35, 1.35), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(profit_label, "rotation", randf_range(-0.15, 0.15), 0.12)
		t.parallel().tween_property(profit_label, "modulate", Color(1.8, 1.8, 0.3, 1.0), 0.12)
		t.parallel().tween_property(profit_label, "scale", Vector2(1.0, 1.0), 0.25).set_delay(0.12).set_trans(Tween.TRANS_ELASTIC)
		t.parallel().tween_property(profit_label, "rotation", 0.0, 0.2).set_delay(0.12)
		t.parallel().tween_property(profit_label, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.25).set_delay(0.12)

func update_profit_display() -> void:
	if profit_label:
		profit_label.text = "Profit Lost: -$" + str(displayed_profit)

func set_suspicion(score: float, is_active: bool) -> void:
	current_suspicion = score
	update_detect_display(score)
	
	# Red screen edge effect
	var normalized = clamp(score / 5.0, 0.0, 1.0)
	var target_alpha = normalized * 0.75
	if is_active and score > 0.1:
		target_alpha += 0.25 * abs(sin(Time.get_ticks_msec() / 120.0))
	if vignette_rect:
		vignette_rect.modulate.a = move_toward(vignette_rect.modulate.a, target_alpha, 0.06)

func update_detect_display(score: float) -> void:
	var star_count = int(ceil(score)) # 0 to 5
	var stars_text = ""
	for i in range(5):
		if i < star_count:
			stars_text += "⭐"
		else:
			stars_text += "☆"
	
	# Update Player's NoticeBar
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_node("NoticeBar"):
		var p_bar: Label = player.get_node("NoticeBar")
		p_bar.text = stars_text if star_count > 0 else ""
		
		# Star gained punch tween
		if star_count > prev_star_count:
			p_bar.pivot_offset = p_bar.size * 0.5
			var punch_scale = base_notice_scale * 1.55
			var t = create_tween()
			t.parallel().tween_property(p_bar, "scale", punch_scale, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			t.parallel().tween_property(p_bar, "rotation", randf_range(-0.25, 0.25), 0.12)
			t.parallel().tween_property(p_bar, "modulate", Color(2.5, 0.3, 0.3, 1.0), 0.12)
			t.parallel().tween_property(p_bar, "scale", base_notice_scale, 0.3).set_delay(0.12).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
			t.parallel().tween_property(p_bar, "rotation", 0.0, 0.25).set_delay(0.12)
			t.parallel().tween_property(p_bar, "modulate", Color.WHITE, 0.3).set_delay(0.12)
			
			var cam = get_tree().get_first_node_in_group("main_camera")
			if cam and cam.has_method("add_shake"):
				cam.add_shake(0.28)
	
	prev_star_count = star_count

func show_review(star_rating: int, loss: int) -> void:
	if !review_panel:
		return
	
	if review_stars:
		var st = ""
		for i in range(5):
			st += "⭐" if i < star_rating else "☆"
		review_stars.text = st
		review_stars.scale = Vector2.ONE
	
	if review_loss:
		review_loss.scale = Vector2.ONE
		if loss > 0:
			review_loss.text = "-$" + str(loss) + " Profit Lost"
			review_loss.modulate = Color(1.0, 0.35, 0.35, 1.0)
		else:
			review_loss.text = "Clean Potion (No Loss)"
			review_loss.modulate = Color(0.4, 0.9, 0.4, 1.0)
	
	if review_tween and review_tween.is_valid():
		review_tween.kill()
	
	# Clean & simple fade + slight slide
	review_panel.scale = Vector2.ONE
	review_panel.rotation = 0.0
	review_panel.position = Vector2(0.0, -15.0)
	review_panel.modulate.a = 0.0
	
	review_tween = create_tween()
	review_tween.parallel().tween_property(review_panel, "modulate:a", 1.0, 0.25)
	review_tween.parallel().tween_property(review_panel, "position:y", 0.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	review_tween.tween_interval(3.2)
	review_tween.tween_property(review_panel, "modulate:a", 0.0, 0.35)
