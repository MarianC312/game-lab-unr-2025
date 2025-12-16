extends Node

var current_minigame: Control

func start_minigame(scene: PackedScene, target):
	if current_minigame:
		return
	current_minigame = scene.instantiate()
	current_minigame.completed.connect(_on_minigame_completed.bind(target))
	print(get_minigame_layer())
	get_minigame_layer().add_child(current_minigame)

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_minigame_completed(success: bool, target):
	if success and target.has_method("unlock"):
		target.unlock()

	current_minigame.queue_free()
	current_minigame = null
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func get_minigame_layer() -> CanvasLayer:
	var nodes = get_tree().get_nodes_in_group("minigame_layer")
	if nodes.is_empty():
		push_error("MinigameLayer no encontrado")
		return null
	return nodes[0]
