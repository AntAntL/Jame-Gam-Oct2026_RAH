extends Sprite2D

@onready var PA = $AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(PA.get_animation_list())
	PA.play("WaterAnimation")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
