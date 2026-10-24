extends CanvasLayer

@onready var profit_label: Label = $TopLeft/MarginContainer/ProfitLabel
@onready var vignette_rect: TextureRect = $VignetteRect

# Review notification elements
@onready var review_panel: PanelContainer = $TopRight/ReviewPanel
@onready var review_stars: Label = $TopRight/ReviewPanel/MarginContainer/VBoxContainer/StarsLabel
@onready var review_loss: Label = $TopRight/ReviewPanel/MarginContainer/VBoxContainer/LossLabel

var total_profit_lost: int = 0
var current_suspicion: float = 0.0
var review_tween: Tween = null

func _ready() -> void:
	add_to_group("hud")
	update_profit_display()
	update_detect_display(0.0)
	
	# Programmatic radial red vignette for screen edges
	var gradient_tex = GradientTexture2D.new()
	var gradient = Gradient.new()
	gradient.set_color(0, Color(0.85, 0.05, 0.05, 0.0)) # center transparent
	gradient.set_color(1, Color(0.85, 0.05, 0.05, 0.85)) # edges red
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

func add_profit_lost(amount: int) -> void:
	total_profit_lost += amount
	update_profit_display()
	
	# Scale punch animation on profit label
	if profit_label:
		var t = create_tween()
		t.tween_property(profit_label, "scale", Vector2(1.2, 1.2), 0.1)
		t.tween_property(profit_label, "scale", Vector2(1.0, 1.0), 0.15)

func update_profit_display() -> void:
	if profit_label:
		profit_label.text = "Profit Lost: -$" + str(total_profit_lost)

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
		var p_bar = player.get_node("NoticeBar")
		p_bar.text = stars_text if star_count > 0 else ""

func show_review(star_rating: int, loss: int) -> void:
	if !review_panel:
		return
	
	if review_stars:
		var st = ""
		for i in range(5):
			st += "⭐" if i < star_rating else "☆"
		review_stars.text = st
	
	if review_loss:
		if loss > 0:
			review_loss.text = "-$" + str(loss) + " Profit Lost"
			review_loss.modulate = Color(1.0, 0.35, 0.35, 1.0)
		else:
			review_loss.text = "Clean Potion (No Loss)"
			review_loss.modulate = Color(0.4, 0.9, 0.4, 1.0)
	
	if review_tween and review_tween.is_valid():
		review_tween.kill()
	
	review_panel.modulate.a = 0.0
	review_tween = create_tween()
	review_tween.tween_property(review_panel, "modulate:a", 1.0, 0.25)
	review_tween.tween_interval(3.5)
	review_tween.tween_property(review_panel, "modulate:a", 0.0, 0.4)
