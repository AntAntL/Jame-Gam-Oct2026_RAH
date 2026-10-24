extends RigidBody2D

var item_name: String = ""

func set_item(p_name: String, p_texture: Texture2D) -> void:
	item_name = p_name
	if has_node("Sprite2D") and p_texture != null:
		var spr: Sprite2D = $Sprite2D
		spr.texture = p_texture
		spr.scale = Vector2(0.195, 0.195)
