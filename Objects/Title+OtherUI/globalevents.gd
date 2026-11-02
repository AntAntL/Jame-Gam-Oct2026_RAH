extends Node
signal pricemult
var potionicon = {
	"redB": preload("res://Objects/Sprites/World/Interactable-Main/HealthBottle.png"),
	"redF": preload("res://Objects/Sprites/World/Interactable-Main/HealthTriBottle.png"),
	"redV": preload("res://Objects/Sprites/World/Interactable-Main/HealthVial.png"),
	"blueB": preload("res://Objects/Sprites/World/Interactable-Main/BlueBottle.png"),
	"blueF": preload("res://Objects/Sprites/World/Interactable-Main/BlueTriBottle.png"),
	"blueV": preload("res://Objects/Sprites/World/Interactable-Main/BlueVials.png"),
	"yellowB": preload("res://Objects/Sprites/World/Interactable-Main/YellowBottle.png"),
	"yellowF": preload("res://Objects/Sprites/World/Interactable-Main/YellowTriBottle.png"),
	"yellowV": preload("res://Objects/Sprites/World/Interactable-Main/YellowVial.png"),
	"greenB": preload("res://Objects/Sprites/World/Interactable-Main/GreenBottle.png"),
	"greenF": preload("res://Objects/Sprites/World/Interactable-Main/GreenTriBottle.png"),
	"greenV": preload("res://Objects/Sprites/World/Interactable-Main/GreenVial.png"),
}

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
	if get_upgrade_cost() > abs(Globals.profit_loss):
		print("too poor buddy")
		return
		
	Globals.profit_loss -= get_upgrade_cost()
	
	potionmulti += 2
	print ("pmult is", potionmulti)
	
func get_upgrade_cost() -> int:
	return int(100 * ((potionmulti + 1) ** 1.5)) 
