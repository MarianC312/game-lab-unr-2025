extends Control
@onready var sfx_stream_player: AudioStreamPlayer = $SFXStreamPlayer
const HOVER = preload("res://Sounds/SFX/UI/Seleccionar y hover/Hover.wav")
const ABRIR_LIBRETA = preload("res://Sounds/SFX/Libreta/Paginas/Abrir libreta.wav")
const CERRAR_LIBRETA_ = preload("res://Sounds/SFX/Libreta/Paginas/Cerrar Libreta .wav")
const CONTINUAR_HACHAZO_2 = preload("res://Sounds/SFX/UI/Seleccionar menu/Continuar hachazo 2.wav")

@onready var m_01_item_v_box_container: VBoxContainer = $VBoxContainer2/HBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Map01VBoxContainer1/HBoxContainer/M01ItemVBoxContainer
@onready var m_02_item_v_box_container: VBoxContainer = $VBoxContainer2/HBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Map02VBoxContainer2/HBoxContainer/M02ItemVBoxContainer
@onready var m_03_item_v_box_container: VBoxContainer = $VBoxContainer2/HBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Map03VBoxContainer3/HBoxContainer/M03ItemVBoxContainer
@onready var m_04_item_v_box_container: VBoxContainer = $VBoxContainer2/HBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Map04VBoxContainer4/HBoxContainer/M04ItemVBoxContainer
@onready var mapa_01_label: Label = $VBoxContainer2/HBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Map01VBoxContainer1/Mapa01Label
@onready var mapa_02_label: Label = $VBoxContainer2/HBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Map02VBoxContainer2/Mapa02Label
@onready var mapa_03_label: Label = $VBoxContainer2/HBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Map03VBoxContainer3/Mapa03Label
@onready var mapa_04_label: Label = $VBoxContainer2/HBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Map04VBoxContainer4/Mapa04Label
@onready var map_01v_box_container_1: VBoxContainer = $VBoxContainer2/HBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Map01VBoxContainer1
@onready var map_02v_box_container_2: VBoxContainer = $VBoxContainer2/HBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Map02VBoxContainer2
@onready var map_03v_box_container_3: VBoxContainer = $VBoxContainer2/HBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Map03VBoxContainer3
@onready var map_04v_box_container_4: VBoxContainer = $VBoxContainer2/HBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Map04VBoxContainer4

const MENU_STYLE_01 = preload("res://Materials/MenuStyle01.tres")

func _ready() -> void:
	GameManager.toggle_journal.connect(_on_toggle_journal)
	# _refresh_interactables()

func _on_toggle_journal() -> void:
	if visible:
		_play_sfx(CERRAR_LIBRETA_)
	else:
		_play_sfx(ABRIR_LIBRETA) 
	for label in m_01_item_v_box_container.get_children():
		label.queue_free()
	_refresh_interactables()

func _refresh_interactables() -> void:
	for interactable in SceneManagerMap01._get_interactables_names():
		var label := Button.new()
		label.theme = MENU_STYLE_01
		label.theme_type_variation = "FlatButton"
		label.text = interactable if SceneManagerMap01._already_interacted(interactable) else "???"
		label.flat = true
		label.add_theme_font_size_override("font_size", 24)
		label.mouse_entered.connect(_on_hover)
		label.pressed.connect(_play_sfx.bind(CONTINUAR_HACHAZO_2))
		m_01_item_v_box_container.add_child(label)
	
	for interactable in SceneManagerMap02._get_interactables_names():
		var label := Button.new()
		label.theme = MENU_STYLE_01
		label.theme_type_variation = "FlatButton"
		label.text = interactable if SceneManagerMap02._already_interacted(interactable) else "???"
		label.flat = true
		label.add_theme_font_size_override("font_size", 24)
		label.mouse_entered.connect(_on_hover)
		label.pressed.connect(_play_sfx.bind(CONTINUAR_HACHAZO_2))
		m_02_item_v_box_container.add_child(label)
		
	for interactable in SceneManagerMap03._get_interactables_names():
		var label := Button.new()
		label.theme = MENU_STYLE_01
		label.theme_type_variation = "FlatButton"
		label.text = interactable if SceneManagerMap03._already_interacted(interactable) else "???"
		label.flat = true
		label.add_theme_font_size_override("font_size", 24)
		label.mouse_entered.connect(_on_hover)
		label.pressed.connect(_play_sfx.bind(CONTINUAR_HACHAZO_2))
		m_03_item_v_box_container.add_child(label)
		
	for interactable in SceneManagerMap04._get_interactables_names():
		var label := Button.new()
		label.theme = MENU_STYLE_01
		label.theme_type_variation = "FlatButton"
		label.text = interactable if SceneManagerMap04._already_interacted(interactable) else "???"
		label.flat = true
		label.add_theme_font_size_override("font_size", 24)
		label.mouse_entered.connect(_on_hover)
		label.pressed.connect(_play_sfx.bind(CONTINUAR_HACHAZO_2))
		m_04_item_v_box_container.add_child(label)
	
	for scene in GameManager.get_game_flow_names():
		match scene:
			"Map01":
				mapa_01_label.text = "journal_map_01" if GameManager.get_scene_state(scene) else "???"
				if GameManager.get_current_scene_name() == "Mapa01" && not map_01v_box_container_1.visible:
					map_01v_box_container_1.show()
			"Map02":
				mapa_02_label.text = "journal_map_02" if GameManager.get_scene_state(scene) else "???"
				if GameManager.get_current_scene_name() == "Mapa02" && not map_02v_box_container_2.visible:
					map_02v_box_container_2.show()
			"Map03":
				mapa_03_label.text = "journal_map_03" if GameManager.get_scene_state(scene) else "???"
				if GameManager.get_current_scene_name() == "Mapa03" && not map_03v_box_container_3.visible:
					map_03v_box_container_3.show()
			"Map04":
				mapa_04_label.text = "journal_map_04" if GameManager.get_scene_state(scene) else "???"
				if GameManager.get_current_scene_name() == "Mapa03" && not map_04v_box_container_4.visible:
					map_04v_box_container_4.show()
			

func _on_volver_pressed() -> void:
	_play_sfx(CONTINUAR_HACHAZO_2)
	GameManager._toggle_journal()

func _play_sfx(sfx : Resource) -> void:
	sfx_stream_player.stream = sfx
	sfx_stream_player.play()

func _on_hover() -> void:
	sfx_stream_player.stream = HOVER
	sfx_stream_player.play()
