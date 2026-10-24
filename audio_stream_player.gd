extends AudioStreamPlayer

func _ready():
	# Connect the finished signal to a local function
	finished.connect(_on_audio_finished)
	play()

func _on_audio_finished():
	play() # Restarts the track immediately
