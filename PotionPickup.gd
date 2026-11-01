extends Area2D
@export var potiontype: String = "blueB"


func _ready() -> void:
	input_event.connect(pickup)

func pickup (_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Inventory.add(potiontype):
			queue_free()
		else:
			print ("fullinv")
			
func price() -> int:
		return Globalevents.potionscost[potiontype]["price"] * Globalevents.potionmulti
