extends Node

@onready var pause_menu = $UI/PauseMenu
@onready var map = $Map
@onready var player = $Player

var current_map: Node = null

func _init() -> void:
	pass


func _process(_delta: float) -> void:
	pass

func _ready() -> void:
	GameManager.toggle_pause.connect(_toggle_pause)
	pause_menu.visible = false
	load_map("res://Scenes/Prototype/Prototype.tscn")

func _input(_event: InputEvent) -> void:
	pass

func _toggle_pause() -> void:
	print("Toggled pause: ", GameManager._get_pause())
	if GameManager._get_pause():
		current_map.process_mode = Node.PROCESS_MODE_DISABLED
		pause_menu.visible = true
	else:
		current_map.process_mode = Node.PROCESS_MODE_INHERIT
		pause_menu.visible = false


func load_map(path) -> void:
	if current_map:
		current_map.queue_free()
	var new_map = load(path).instantiate()
	if new_map.has_signal("map_ready"):
		print("El mapa tiene la señal ready.")
		new_map.map_ready.connect(_on_map_ready)
	map.add_child(new_map)
	current_map = new_map # Corregir que el nuevo mapa cargado pase a ser hijo del nodo Map

func _on_map_ready() -> void:
	var spawn = get_tree().get_first_node_in_group("CharSpawn")
	print(player.global_position)
	print(spawn.global_position)
	player.global_position = spawn.global_position
