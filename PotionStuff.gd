extends Node2D
var potionmulti = 0
var potioncost = {
	"red":  {"name": "Red Potion","price": 10},
	"blue": {"name": "Blue Potion","price": 12},
}
func _ready() -> void:
	print ("upTest")
	Globalevents.pricemult.connect(increasepotionmult)
func increasepotionmult():
	potionmulti += 2
	print ("pmult is", potionmulti)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
