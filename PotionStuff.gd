extends Node2D
var potionmulti = 0
var potioncost = {
	"redB":  {"name": "Red Potion","price": 10},
	"redL": {"name": "Blue Potion","price": 15},
	"redV": {"name": "Blue Potion","price": 12},
	"blueB": {"name": "Blue Potion","price": 12},
	"blueL": {"name": "Blue Potion","price": 20},
	"blueV": {"name": "Blue Potion","price": 16},
	"greenB": {"name": "Blue Potion","price": 16},
	"greenL": {"name": "Blue Potion","price": 25},
	"greenV": {"name": "Blue Potion","price": 20},
	"yellowB": {"name": "Blue Potion","price": 20},
	"yellowL": {"name": "Blue Potion","price": 30},
	"yellowV": {"name": "Blue Potion","price": 25},
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
