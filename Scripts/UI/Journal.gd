extends Control

@onready var sfx_stream_player: AudioStreamPlayer = $SFXStreamPlayer
const HOVER = preload("res://Sounds/SFX/UI/Seleccionar y hover/Hover.wav")
const ABRIR_LIBRETA = preload("res://Sounds/SFX/Libreta/Paginas/Abrir libreta.wav")
const CERRAR_LIBRETA_ = preload("res://Sounds/SFX/Libreta/Paginas/Cerrar Libreta .wav")
const CONTINUAR_HACHAZO_2 = preload("res://Sounds/SFX/UI/Seleccionar menu/Continuar hachazo 2.wav")
const VOLTEAR_PAGINA_1 = preload("uid://b1pdlc1eyo77f")

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
@onready var photo_container: TextureRect = $BoxContainer/JournalOpened/HBoxContainer/HBoxContainer/TextureRect
@onready var text_content_label: RichTextLabel = $BoxContainer/JournalOpened/HBoxContainer/HBoxContainer2/RichTextLabel

var contenido : Dictionary = {
	"Mapa01": {},
	"Mapa02": {},
	"Mapa03": {},
	"Mapa04": {}
}

var current_photo : Resource
var current_text := "
- Llevar a diario el cintillo celeste 
- F.O.R.A: prendas rojas, pañuelos, cintas
- Manuel: dejarle la caja
"

const MENU_STYLE_01 = preload("res://Materials/MenuStyle01.tres")

func _ready() -> void:
	GameManager.toggle_journal.connect(_on_toggle_journal)
	text_content_label.text = current_text
	# _refresh_interactables()

func _on_toggle_journal() -> void:
	if visible:
		_play_sfx(CERRAR_LIBRETA_)
	else:
		_play_sfx(ABRIR_LIBRETA)
		for label in m_01_item_v_box_container.get_children():
			label.queue_free()
		for label in m_02_item_v_box_container.get_children():
			label.queue_free()
		for label in m_03_item_v_box_container.get_children():
			label.queue_free()
		for label in m_04_item_v_box_container.get_children():
			label.queue_free()
		_refresh_interactables()

func _refresh_interactables() -> void:
	var interactables = (
		SceneManagerMap01.get_interactables() +
		SceneManagerMap02.get_interactables() +
		SceneManagerMap03.get_interactables() +
		SceneManagerMap04.get_interactables()
	)
	interactables.sort_custom(func(a, b): 
		var num_a = a.object_name.split(".")[0].strip_edges().to_int()
		var num_b = b.object_name.split(".")[0].strip_edges().to_int()
		return num_a < num_b
	)
	
	for interactable in interactables:
		contenido[interactable.map].set(
			interactable.object_name,
			{
				"photo": interactable.photo,
				"text_content": interactable.text_content,
				"display": SceneManagerMap01._already_interacted(interactable.object_name) or SceneManagerMap02._already_interacted(interactable.object_name) or SceneManagerMap03._already_interacted(interactable.object_name) or SceneManagerMap04._already_interacted(interactable.object_name)
			}
		)
	print(contenido)
	# Considerar que esto se puede mover al gameflow para no ser repetitivo y comentar
	# el queue_free del toggle, si bien no es pesado se evitan operaciones innecesarias.
	# Por falta de tiempo está así pero quizás se podría conectar una señal en la creción
	# de los botones para detectar cuando se interactúa con el objeto con el que está conectado
	# a fin de mostrar el nombre y activar sus funciones en lugar de ???
	for map in contenido.keys():
		for ikey in contenido[map].keys():
			#var interaction : bool
			#match map:
				#"Mapa01":
					#interaction = SceneManagerMap01._already_interacted(ikey)
				#"Mapa02":
					#interaction = SceneManagerMap02._already_interacted(ikey)
				#"Mapa03":
					#interaction = SceneManagerMap03._already_interacted(ikey)
				#"Mapa04":
					#interaction = SceneManagerMap04._already_interacted(ikey)
			_create_button(ikey, map, contenido[map][ikey].photo, contenido[map][ikey].text_content, contenido[map][ikey].display)
	# buscar error donde a partir del 2do mapa la box del mapa 1 desaparece
	#if not map_01v_box_container_1.visible and GameManager.get_scene_state("Map01"):
		#map_01v_box_container_1.show()
	
	for scene in GameManager.get_game_flow_names():
		match scene:
			"Map01":
				mapa_01_label.text = "journal_map_01" if GameManager.get_scene_state(scene) else "???"
				if GameManager.get_scene_state(scene) && not map_01v_box_container_1.visible:
					map_01v_box_container_1.show()
			"Map02":
				mapa_02_label.text = "journal_map_02" if GameManager.get_scene_state(scene) else "???"
				if GameManager.get_scene_state(scene) && not map_02v_box_container_2.visible:
					map_02v_box_container_2.show()
			"Map03":
				mapa_03_label.text = "journal_map_03" if GameManager.get_scene_state(scene) else "???"
				if GameManager.get_scene_state(scene) && not map_03v_box_container_3.visible:
					map_03v_box_container_3.show()
			"Map04":
				mapa_04_label.text = "journal_map_04" if GameManager.get_scene_state(scene) else "???"
				if GameManager.get_scene_state(scene) && not map_04v_box_container_4.visible:
					map_04v_box_container_4.show()

func _create_button(label_text : String, map : String, photo : Resource, text_content : String, interacted : bool = false) -> void:
	var label := Button.new()
	label.theme = MENU_STYLE_01
	label.theme_type_variation = "FlatButton"
	label.text = label_text if interacted else "???"
	label.flat = true
	label.add_theme_font_size_override("font_size", 24)
	label.mouse_entered.connect(_on_hover)
	label.pressed.connect(
		func():
			_play_sfx(VOLTEAR_PAGINA_1)
			_update_content(photo, text_content, interacted)
	)
	match map:
		"Mapa01":
			m_01_item_v_box_container.add_child(label)
		"Mapa02":
			m_02_item_v_box_container.add_child(label)
		"Mapa03":
			m_03_item_v_box_container.add_child(label)
		"Mapa04":
			m_04_item_v_box_container.add_child(label)

func _on_volver_pressed() -> void:
	_play_sfx(CONTINUAR_HACHAZO_2)
	GameManager._toggle_journal()

func _play_sfx(sfx : Resource) -> void:
	sfx_stream_player.stream = sfx
	sfx_stream_player.play()

func _on_hover() -> void:
	sfx_stream_player.stream = HOVER
	sfx_stream_player.play()

func _update_content(photo: Resource, text_content: String, interacted := false) -> void:
	if interacted:
		print(photo)
		print(text_content)
		photo_container.texture = photo
		text_content_label.text = text_content
	else:
		print("Debes desbloquear este contenido antes de poder verlo.")
		text_content_label.text = "Debes desbloquear este contenido antes de poder verlo."
