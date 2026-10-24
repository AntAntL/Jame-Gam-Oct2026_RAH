extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer
@onready var area: Area2D = $Area2D
var witch_looking = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	witch_looking = !witch_looking
	sprite.flip_h = witch_looking
	timer.wait_time = randf() * 5
	
	var bodies = area.get_overlapping_bodies()
	
	for body in bodies:
		if body.is_in_group("item") and !body.is_in_group("inside_cauldron"):
			print("seen")
