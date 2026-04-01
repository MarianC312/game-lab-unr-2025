extends Node

@onready var pause_menu : Control = $UI/PauseMenu
# @onready var options_menu: Control = $UI/OptionsMenu
@onready var map : Node3D = $Map
@onready var player : CharacterBody3D = $Player
@onready var loading : Control = $UI/Loading
@onready var journal: Control = $UI/Journal
@onready var controls_menu: Control = $UI/ControlsMenu

var first_load : bool = true # true
var current_map: Node = null

func _init() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _ready() -> void:
	GameManager.toggle_pause.connect(_on_toggle_pause)
	GameManager.toggle_loading.connect(_on_toggle_loading)
	GameManager.toggle_journal.connect(_on_toggle_journal)
	GameManager.toggle_controls.connect(_on_toggle_controls)
	loading.scene_loaded.connect(_on_scene_loaded)
	pause_menu.visible = false
	loading.visible = true
	SceneTransitions.fade_in()
	await SceneTransitions.fade_complete
	GameManager.load_new_map("")

func _input(_event: InputEvent) -> void:
	pass

func _on_toggle_pause() -> void:
	# print("Toggled pause: ", GameManager._is_game_paused())
	if GameManager._is_game_paused() and not GameManager._is_game_loading():
		current_map.process_mode = Node.PROCESS_MODE_DISABLED
		pause_menu.visible = true
	else:
		current_map.process_mode = Node.PROCESS_MODE_INHERIT
		pause_menu.visible = false

func _on_toggle_loading() -> void:
	# print("Toggled loading: ", GameManager._get_current_state())
	if GameManager._is_game_loading() and not GameManager._is_game_paused():
		if not first_load:
			SceneTransitions.fade_out()
			await SceneTransitions.fade_complete
		else:
			first_load = false
		loading.visible = true
		loading.process_mode = Node.PROCESS_MODE_INHERIT
		loading._load_new_scene()
	else:
		loading.visible = false
		loading.process_mode = Node.PROCESS_MODE_DISABLED

func load_map(packed_scene) -> void:
	if packed_scene:
		SceneTransitions.fade_out()
		await SceneTransitions.fade_complete
		if current_map:
			current_map.queue_free()
		var new_map = packed_scene.instantiate()
		map.add_child(new_map)
		current_map = new_map # Corregir que el nuevo mapa cargado pase a ser hijo del nodo Map
		GameManager._switch_scene_loaded()
		_on_map_ready()
	else:
		print("Ocurrió un error al cargar el mapa: ", packed_scene)

func _on_map_ready() -> void:
	if GameManager.current_scene.playable:
		var spawn = get_tree().get_first_node_in_group("CharSpawn")
		if spawn != null:
			player.global_position = spawn.global_position
			print("Actualizando posición del player...")
			player.start_first_dialogue() # hacer q solo se ejecute en el primer mapa
		else:
			print("Spawn no encontrado: ", spawn)
	player._clear_movement()
	loading.visible = false
	SceneTransitions.fade_in()
	await SceneTransitions.fade_complete
	loading._reset_progress_bar_value()
	loading.process_mode = PROCESS_MODE_DISABLED
	GameManager._toggle_playing()

func _on_scene_loaded(new_scene) -> void:
	print("Escena cargada correctamente...")
	loading.process_mode = PROCESS_MODE_DISABLED
	load_map(new_scene)
	

func _on_toggle_journal() -> void:
	if journal.visible:
		journal.hide()
	else:
		journal.show()
		
func _on_toggle_controls() -> void:
	if controls_menu.visible:
		controls_menu.hide()
	else:
		controls_menu.show()
