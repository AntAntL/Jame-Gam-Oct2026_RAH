extends Node
signal update

const totalpotionheld = 5

var potionheld: Array[String] = []

func add(id: String) -> bool:
	if potionheld.size() >= totalpotionheld:
		return false
	potionheld.append(id)
	update.emit()
	return true
	
func throw(id: String) -> bool:
	var index = potionheld.find(id)
	if index == -1:
		return false
	potionheld.remove_at(index)
	update.emit()
	return true
