extends Node3D

@onready var item_list: ItemList = $UI/CanvasLayer15/ItemList
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var forestal: Node3D = $Mundo/Forestal
@onready var camera_3d: Camera3D = $Camera3D
@onready var sfx_stream_player: AudioStreamPlayer = $SFXStreamPlayer

const ESCRIBIR_4 = preload("res://Sounds/SFX/Escribir Libreta (Notas)/Escribir 4.ogg")

signal map_ready

var player

func _ready() -> void:
	# ver o revisar si necesitamos fadein en el sonido
	# print("Region map: ", NavigationServer3D.region_get_map($NavigationRegion3D.get_rid()))
	audio_stream_player.play()
	camera_3d.make_current()
	SceneManagerMap04.registered_interaction.connect(_on_registered_interaction)
	process_mode = Node.PROCESS_MODE_INHERIT
	player = get_tree().get_nodes_in_group("Player")
	for interactable in get_tree().get_nodes_in_group("Interactable"):
		SceneManagerMap04.set_interactable(interactable)
	emit_signal("map_ready")
	SceneManagerMap04._get_interactables_names()
	print("Mapa listo!")

func _process(_delta: float) -> void:
	# print(SceneManagerMap01._get_interactables())
	# print("Stream line: ", audio_stream_player.get_playback_position())
	pass

func _update_item_list() -> void:
	for i in range(item_list.item_count):
		var interactable = item_list.get_item_text(i)
		if SceneManagerMap04._already_interacted(interactable):
			item_list.set_item_disabled(i, true)
		else:
			item_list.set_item_disabled(i, false)


func _on_registered_interaction(interactable_name : String) -> void:
	_play_sfx(ESCRIBIR_4)
	if SceneManagerMap04._get_show_all_interacts():
		item_list.clear()
		for interactable in SceneManagerMap04._get_interactables_names():
			item_list.add_item(interactable)
	else:
		item_list.add_item(interactable_name)
	_update_item_list()

func _play_sfx(sfx : Resource) -> void:
	sfx_stream_player.stream = sfx
	sfx_stream_player.play()
