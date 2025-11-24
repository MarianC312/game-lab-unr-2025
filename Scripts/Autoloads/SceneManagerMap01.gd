extends Node

var interactables : Dictionary = {
	"Cuadro": false,
	"Puerta01": false,
	"Cuaderno": false,
	"Mate": false,
	"Puerta04": false
}

signal registered_interaction

var show_all_interacts : bool = false

func _get_interactables() -> Dictionary:
	return interactables

func _get_show_all_interacts() -> bool:
	return show_all_interacts

func _set_show_all_interacts(state : bool) -> void:
	show_all_interacts = state

func _register_interaction(interactable_name : String) -> void:
	interactables[interactable_name] = true
	if not show_all_interacts and interactable_name == "Puerta04":
		_set_show_all_interacts(true)
	registered_interaction.emit(interactable_name)

func _already_interacted(interactable_name : String) -> bool:
	return interactables[interactable_name]

func _interacted_with_all() -> bool:
	var resp = true
	for interactable_name in interactables:
		print(interactable_name, ": ", interactables[interactable_name])
		if not interactables[interactable_name]:
			resp = false
			continue
	return resp
