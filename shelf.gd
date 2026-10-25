extends MarginContainer

signal item_selected(item_id: String, texture: Texture2D)

@onready var grid: GridContainer = $GridContainer

func _ready() -> void:
	if grid:
		for child in grid.get_children():
			if child is Button:
				var item_id: String = child.name.to_snake_case()
				var tex: Texture2D = child.icon
				child.pressed.connect(func(): _on_item_pressed(item_id, tex))

func _on_item_pressed(item_id: String, texture: Texture2D) -> void:
	item_selected.emit(item_id, texture)
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_held_item"):
		player.set_held_item(item_id, texture)
