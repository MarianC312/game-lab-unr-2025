extends Node

@export var interactables : Dictionary = {}
const JOURNAL_NAME := "1. Cuaderno"

signal registered_interaction

var show_all_interacts : bool = false

func _ready() -> void:
	GameManager.restart_game.connect(_on_restart_game)

func set_interactable(interactable) -> void:
	var interactable_name = interactable.get_object_name() if interactable.has_method("get_object_name") else interactable.get_npc_name()
	if interactables.find_key(interactable_name) == null:
		interactables.set(interactable_name, {
			"object": interactable,
			"interacted": false,
			"required": interactable.required,
			"content": {
				"object_name": interactable_name,
				"map": interactable.map,
				"photo": interactable.photo,
				"text_content": interactable.text_content
			}
		})

func interactable_is_locked(interactable : String) -> bool:
	if interactables[interactable].object.has_method("is_locked"):
		return interactables[interactable].object.is_locked() if interactables[interactable].object.has_method("is_locked") else false
	else:
		return false

func interactable_start_minigame(interactable : String) -> void:
	if interactables[interactable].object.has_method("get_minigame"):
		MinigameManager.start_minigame(interactables[interactable].object.get_minigame(), interactables[interactable].object)

func get_interactables() -> Array:
	var objects = interactables.values().map(func(item): return item["content"])
	return objects

func _get_interactables_names() -> Array:
	var keys := interactables.keys() 
	keys.sort()
	return keys

func _get_show_all_interacts() -> bool:
	return show_all_interacts

func _set_show_all_interacts(state : bool) -> void:
	show_all_interacts = state

func _register_interaction(interactable_name : String) -> void:
	if interactables.has(interactable_name):
		interactables[interactable_name].interacted = true
		#if not show_all_interacts and interactable_name == "10. Ir al cruce":
			#_set_show_all_interacts(true)
		registered_interaction.emit(interactable_name)
		if interactables[interactable_name].object.has_method("despawn_on_interaction"):
			if interactables[interactable_name].object.despawn_on_interaction():
				interactables[interactable_name].object.despawn_object()

func _already_interacted(interactable_name : String) -> bool:
	# print("From _already_interacted: ", interactables)
	if interactables.has(interactable_name):
		return interactables[interactable_name].interacted
	else:
		return false

func _interacted_with_all() -> bool:
	# Acomodar que va a decidir si completa el mapa
	return true

func already_interacted_with_journal() -> bool:
	return _already_interacted(JOURNAL_NAME)

func _on_restart_game() -> void:
	interactables = {}
	show_all_interacts = false
