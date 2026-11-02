extends StaticBody2D

var InRange: bool = false

func _ready() -> void:
	body_entered.connect(PlayerEntered)
	body_exited.connect(PlayerExited)
	
func PlayerEntered(body:Node) -> void:
	if body.is_in_group ("player"):
		InRange = true
func PlayerExited(body:Node) -> void:
	if body.is_in_group ("player"):
		InRange = false
func _unhandled_input(event: InputEvent) -> void:
	if InRange and event.is_action_pressed("Interact"):
