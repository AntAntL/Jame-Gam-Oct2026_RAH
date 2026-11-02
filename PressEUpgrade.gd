extends Area2D

var InRange: bool = false
@onready var upgrade_screen: CanvasItem = $"../UpgradeScreen"

func _ready() -> void:
	print ("ready")
	body_entered.connect(PlayerEntered)
	body_exited.connect(PlayerExited)
	
func PlayerEntered(body:Node) -> void:
	if body.is_in_group ("player"):
		print ("inrange")
		InRange = true
func PlayerExited(body:Node) -> void:
	if body.is_in_group ("player"):
		InRange = false
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		print("interact pressed, InRange = ", InRange)
		if InRange:
			upgrade_screen.visible = not upgrade_screen.visible
			print("shown")
