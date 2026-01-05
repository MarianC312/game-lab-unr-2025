extends Control

@onready var m_01_item_v_box_container: VBoxContainer = $VBoxContainer2/HBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Map01VBoxContainer/HBoxContainer/M01ItemVBoxContainer
@onready var mapa_01_label: Label = $VBoxContainer2/HBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Map01VBoxContainer/Mapa01Label
@onready var mapa_02_label: Label = $VBoxContainer2/HBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Map02VBoxContainer2/Mapa02Label
@onready var mapa_03_label: Label = $VBoxContainer2/HBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Map03VBoxContainer3/Mapa03Label
@onready var mapa_04_label: Label = $VBoxContainer2/HBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Map04VBoxContainer4/Mapa04Label
const MENU_STYLE_01 = preload("res://Materials/MenuStyle01.tres")


func _ready() -> void:
	GameManager.toggle_journal.connect(_on_toggle_journal)
	_refresh_interactables()
	

func _on_toggle_journal() -> void:
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
		m_01_item_v_box_container.add_child(label)
	for scene in GameManager.get_game_flow_names():
		match scene:
			"Map01":
				mapa_01_label.text = "journal_map_01" if GameManager.get_scene_state(scene) else "???"
			"Map02":
				mapa_02_label.text = "journal_map_02" if GameManager.get_scene_state(scene) else "???"
			"Map03":
				mapa_03_label.text = "journal_map_03" if GameManager.get_scene_state(scene) else "???"
			"Map04":
				mapa_04_label.text = "journal_map_04" if GameManager.get_scene_state(scene) else "???"
			

func _on_volver_pressed() -> void:
	GameManager._toggle_journal()
