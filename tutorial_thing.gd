extends Sprite2D

@export var TutorialImage: Texture2D
@export var StartTime: int = 0
@export var ShowTime: int = 10

@onready var timer: Timer = $Timer

var started = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = StartTime
	timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	if !started:
		started = true
		visible = true
		texture = TutorialImage
		
		timer.wait_time = ShowTime
		timer.start()
		
		return
		
	visible = false
