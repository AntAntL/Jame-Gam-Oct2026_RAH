extends Node
signal pricemult

var potionmulti = 1
var potionscost = {
	"redB":  {"name": "Red Bottle","price": 10},
	"redF": {"name": "Red Large","price": 15},
	"redV": {"name": "Red Vial","price": 12},
	"blueB": {"name": "Blue Bottle","price": 12},
	"blueF": {"name": "Blue Flask","price": 20},
	"blueV": {"name": "Blue Vial","price": 16},
	"greenB": {"name": "Green Bottle","price": 16},
	"greenF": {"name": "Green Flask","price": 25},
	"greenV": {"name": "Green Vial","price": 20},
	"yellowB": {"name": "Yellow Bottle","price": 20},
	"yellowF": {"name": "Yellow Flask","price": 30},
	"yellowV": {"name": "Yellow Vial","price": 25},
}
func _ready() -> void:
	pricemult.connect(increasepotionmult)
func increasepotionmult():
	potionmulti += 2
	print ("pmult is", potionmulti)
	
