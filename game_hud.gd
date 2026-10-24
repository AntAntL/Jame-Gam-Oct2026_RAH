extends CanvasLayer

const TrickPopup = preload("res://trick_popup.gd")

@onready var profit_label: Label = $TopLeft/MarginContainer/ProfitLabel
@onready var vignette_rect: TextureRect = $VignetteRect

# Review notification elements
@onready var review_panel: PanelContainer = $TopRight/ReviewPanel
@onready var review_stars: Label = $TopRight/ReviewPanel/MarginContainer/VBoxContainer/StarsLabel
@onready var review_loss: Label = $TopRight/ReviewPanel/MarginContainer/VBoxContainer/LossLabel

# End Screen elements
@onready var end_screen: Control = $EndScreen
@onready var red_overlay: ColorRect = $EndScreen/RedOverlay
@onready var end_content: VBoxContainer = $EndScreen/CenterContainer/Content
@onready var final_score_label: Label = $EndScreen/CenterContainer/Content/ScoreBox/Margin/VBox/FinalScoreLabel
@onready var best_score_label: Label = $EndScreen/CenterContainer/Content/ScoreBox/Margin/VBox/BestScoreLabel
@onready var new_best_label: Label = $EndScreen/CenterContainer/Content/ScoreBox/Margin/VBox/NewBestLabel
@onready var replay_button: Button = $EndScreen/CenterContainer/Content/ReplayButton

const BEST_SCORE_FILE: String = "user://best_score.dat"
var is_game_over: bool = false
var game_over_queued: bool = false

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
	
	if end_screen:
		end_screen.visible = false
	if replay_button:
		replay_button.pressed.connect(_on_replay_pressed)

func _process(_delta: float) -> void:
	pass

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
	
	if score >= 5.0 and not game_over_queued and not is_game_over:
		game_over_queued = true
		get_tree().create_timer(0.45, true, false, true).timeout.connect(trigger_game_over)
	
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
		
		# Subtle star gained bump
		if star_count > prev_star_count:
			p_bar.pivot_offset = p_bar.size * 0.5
			var punch_scale = base_notice_scale * 1.12
			var t = create_tween()
			t.tween_property(p_bar, "scale", punch_scale, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			t.tween_property(p_bar, "scale", base_notice_scale, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
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
			review_loss.text = "Clean Potion"
			review_loss.modulate = Color(0.4, 0.9, 0.4, 1.0)
	
	if review_tween and review_tween.is_valid():
		review_tween.kill()
	
	# Fade
	review_panel.scale = Vector2.ONE
	review_panel.rotation = 0.0
	review_panel.position = Vector2(0.0, -15.0)
	review_panel.modulate.a = 0.0
	
	review_tween = create_tween()
	review_tween.parallel().tween_property(review_panel, "modulate:a", 1.0, 0.25)
	review_tween.parallel().tween_property(review_panel, "position:y", 0.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	review_tween.tween_interval(3.2)
	review_tween.tween_property(review_panel, "modulate:a", 0.0, 0.35)

func load_best_score() -> int:
	if not FileAccess.file_exists(BEST_SCORE_FILE):
		return 0
	var file = FileAccess.open(BEST_SCORE_FILE, FileAccess.READ)
	if file:
		var text = file.get_as_text().strip_edges()
		return text.to_int()
	return 0

func save_best_score(score: int) -> void:
	var file = FileAccess.open(BEST_SCORE_FILE, FileAccess.WRITE)
	if file:
		file.store_string(str(score))

func trigger_game_over() -> void:
	if is_game_over:
		return
	is_game_over = true
	
	var best_score = load_best_score()
	var is_new_best = total_profit_lost > best_score
	if is_new_best:
		best_score = total_profit_lost
		save_best_score(best_score)
	
	if final_score_label:
		final_score_label.text = "Profit Lost: -$" + str(total_profit_lost)
	if best_score_label:
		best_score_label.text = "Best Sabotage: -$" + str(best_score)
	if new_best_label:
		new_best_label.visible = is_new_best
	
	if end_screen and red_overlay and end_content:
		end_screen.visible = true
		end_screen.mouse_filter = Control.MOUSE_FILTER_STOP
		red_overlay.color = Color(0.65, 0.04, 0.04, 0.0)
		end_content.modulate.a = 0.0
		
		# Simple red screen fade-in
		var t = create_tween()
		t.parallel().tween_property(red_overlay, "color:a", 0.88, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		t.tween_callback(func():
			if replay_button:
				replay_button.grab_focus()
		)

func _on_replay_pressed() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
