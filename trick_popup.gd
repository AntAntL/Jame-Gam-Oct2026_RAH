class_name TrickPopup
extends Node2D

static func spawn(parent: Node, world_pos: Vector2, text: String, color: Color = Color(1.0, 0.85, 0.2)) -> void:
	if parent == null:
		return
	
	var label = Label.new()
	label.text = text
	label.top_level = true
	label.global_position = world_pos + Vector2(-60, -30) + Vector2(randf_range(-10.0, 10.0), randf_range(-10.0, 10.0))
	label.z_index = 100
	
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.08, 0.08, 0.08, 1.0))
	label.add_theme_constant_override("outline_size", 8)
	
	parent.add_child(label)
	
	label.pivot_offset = Vector2(50, 15) + Vector2(randf_range(-10.0, 10.0), randf_range(-10.0, 10.0))
	label.scale = Vector2(0.4, 0.4)
	
	var tween = label.create_tween()
	tween.parallel().tween_property(label, "scale", Vector2(1.25, 1.25), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "global_position:y", world_pos.y - 75.0, 0.9)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.1)
	tween.tween_interval(0.4)
	tween.tween_property(label, "modulate:a", 0.0, 0.3)
	tween.tween_callback(label.queue_free)
