extends Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.pressed.connect(press)
	$"../../Label".text = "$" + str(Globalevents.get_upgrade_cost())
	
func press() -> void:
	Globalevents.pricemult.emit()
	print("up")
	$"../../Label".text = "$" + str(Globalevents.get_upgrade_cost())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
