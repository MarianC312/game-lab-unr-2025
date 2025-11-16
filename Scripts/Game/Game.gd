extends Node

@onready var pause_menu = $UI/PauseMenu
@onready var map = $Map
@onready var player = $Player

func _init() -> void:
	pass

func _ready() -> void:
	pause_menu.visible = false
	load_map("res://Scenes/Prototype/Prototype.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		toggle_pause()

func toggle_pause() -> void:
	GameManager._pause()
	pause_menu.visible = !GameManager._get_pause()

func load_map(path) -> void:
	if map:
		map.queue_free()
	var new_map = load(path).instantiate()
	if new_map.has_signal("map_ready"):
		print("El mapa tiene la señal ready.")
		new_map.map_ready.connect(_on_map_ready)
	add_child(new_map)
	map = new_map # Corregir que el nuevo mapa cargado pase a ser hijo del nodo Map

func _on_map_ready() -> void:
	var spawn = get_tree().get_first_node_in_group("CharSpawn")
	print(player.global_position)
	print(spawn.global_position)
	player.global_position = spawn.global_position
