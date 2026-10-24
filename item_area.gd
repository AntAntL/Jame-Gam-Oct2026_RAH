extends Area2D

signal ingredient_added(item_name: String)

var ingredients: Array[String] = []

func _ready() -> void:
	add_to_group("cauldron")

func _on_body_entered(body: Node2D) -> void:
	if (!body.is_in_group("item")):
		return
	
	body.add_to_group("inside_cauldron")
	var item_name = "item"
	if "item_name" in body and body.item_name != "":
		item_name = body.item_name
	
	ingredients.append(item_name)
	ingredient_added.emit(item_name)
	print("Cauldron accepted ingredient: ", item_name, " (Total in brew: ", ingredients.size(), ")")

func get_and_clear_ingredients() -> Array[String]:
	var current = ingredients.duplicate()
	ingredients.clear()
	return current

func get_ingredient_count() -> int:
	return ingredients.size()
