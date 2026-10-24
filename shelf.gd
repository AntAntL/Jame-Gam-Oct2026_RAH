extends MarginContainer

signal item_selected(item_id: String, texture: Texture2D)

@export var item_a_texture: Texture2D = preload("res://Objects/Sprites/World/Unorganized/itema.png")
@export var item_b_texture: Texture2D = preload("res://Objects/Sprites/World/Unorganized/itemb.png")
@export var item_c_texture: Texture2D = preload("res://Objects/Sprites/World/Unorganized/itemc.png")

@onready var btn_a: Button = $VBoxContainer/ItemA
@onready var btn_b: Button = $VBoxContainer/ItemB
@onready var btn_c: Button = $VBoxContainer/ItemC

func _ready() -> void:
	if btn_a:
		btn_a.pressed.connect(func(): _on_item_pressed("itema", item_a_texture))
	if btn_b:
		btn_b.pressed.connect(func(): _on_item_pressed("itemb", item_b_texture))
	if btn_c:
		btn_c.pressed.connect(func(): _on_item_pressed("itemc", item_c_texture))

func _on_item_pressed(item_id: String, texture: Texture2D) -> void:
	item_selected.emit(item_id, texture)
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_held_item"):
		player.set_held_item(item_id, texture)
