extends Node

@export var interactables : Dictionary = {}

signal registered_interaction

var show_all_interacts : bool = false

func set_interactable(interactable) -> void:
	var interactable_name = interactable.get_object_name()
	if interactables.find_key(interactable_name) == null:
		interactables.set(interactable_name, {
			"object": interactable,
			"interacted": false
		})

func interactable_is_locked(interactable : String) -> bool:
	return interactables[interactable].object.is_locked()

func interactable_start_minigame(interactable : String) -> void:
	MinigameManager.start_minigame(interactables[interactable].object.get_minigame(), interactables[interactable].object)

func _get_interactables_names() -> Array:
	return interactables.keys()

func _get_show_all_interacts() -> bool:
	return show_all_interacts

func _set_show_all_interacts(state : bool) -> void:
	show_all_interacts = state

func _register_interaction(interactable_name : String) -> void:
	interactables[interactable_name].interacted = true
	if not show_all_interacts and interactable_name == "Puerta04":
		_set_show_all_interacts(true)
	registered_interaction.emit(interactable_name)

func _already_interacted(interactable_name : String) -> bool:
	if interactables.has(interactable_name):
		return interactables[interactable_name]["interacted"]
	else:
		return false

func _interacted_with_all() -> bool:
	var resp = true
	for interactable in interactables:
		print(interactable, ": ", interactables[interactable])
		if not interactables[interactable].interacted:
			resp = false
			continue
	return resp
