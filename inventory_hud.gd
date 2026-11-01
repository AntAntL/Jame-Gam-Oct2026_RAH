extends CanvasLayer

const potionslot = preload("res://Potionslots.tscn")

var potionicon = {
	"redB": preload("res://Objects/Sprites/World/Interactable-Main/HealthBottle.png"),
	"redL": preload("res://Objects/Sprites/World/Interactable-Main/HealthTriBottle.png"),
	"redV": preload("res://Objects/Sprites/World/Interactable-Main/HealthVial.png"),
	"blueB": preload("res://Objects/Sprites/World/Interactable-Main/BlueBottle.png"),
	"blueL": preload("res://Objects/Sprites/World/Interactable-Main/BlueTriBottle.png"),
	"blueV": preload("res://Objects/Sprites/World/Interactable-Main/BlueVials.png"),
	"yellowB": preload("res://Objects/Sprites/World/Interactable-Main/YellowBottle.png"),
	"yellowL": preload("res://Objects/Sprites/World/Interactable-Main/YellowTriBottle.png"),
	"yellowV": preload("res://Objects/Sprites/World/Interactable-Main/YellowVial.png"),
	"greenB": preload("res://Objects/Sprites/World/Interactable-Main/GreenBottle.png"),
	"greenL": preload("res://Objects/Sprites/World/Interactable-Main/GreenTriBottle.png"),
	"greenV": preload("res://Objects/Sprites/World/Interactable-Main/GreenVial.png"),
}

@onready var row: HBoxContainer = $HBoxContainer

func _ready() -> void:
	Inventory.update.connect(refresh)
	refresh()

func refresh() -> void:
	for child in row.get_children():
		child.queue_free()
	
	for index in Inventory.totalpotionheld:
		var slot = potionslot.instantiate()
		row.add_child(slot)
		if index < Inventory.potionheld.size():
			var id = Inventory.potionheld[index]
			slot.get_node("TextureRect").texture = potionicon[id]
		slot.get_node("Label").text = ""

func _process(delta: float) -> void:
	pass
