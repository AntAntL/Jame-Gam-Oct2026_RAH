extends CanvasLayer

const potionslot = preload("res://Potionslots.tscn")

@onready var row: HBoxContainer = $HBoxContainer

func _ready() -> void:
	Inventory.update.connect(refresh)
	refresh()

func refresh() -> void:
	for child in row.get_children():
		child.queue_free()

	for index in Inventory.totalpotionheld:
		var slot = potionslot.instantiate()
		slot.custom_minimum_size = Vector2(64, 64)
		row.add_child(slot)
		if index < Inventory.potionheld.size():
			var id = Inventory.potionheld[index]
			slot.get_node("TextureRect").texture = Globalevents.potionicon[id]
		slot.get_node("Label").text = ""
