extends Area2D
@export var potiontype: String = "red"


func _ready() -> void:
	input_event.connect(pickup)

func pickup (_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button.index == MOUSE_BUTTON_LEFT:
		if Inventory.add(self):
			hide()
			input_pickable = false
func price() -> int:
	var check = get_parent().potioncost
	return check[potiontype]["price"] * Globalevents.potionmulti
