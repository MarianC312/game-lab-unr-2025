extends Node3D

@onready var item_list: ItemList = $UI/CanvasLayer15/ItemList
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var camera_3d: Camera3D = $Camera3D
@onready var char_spawn: Node3D = $Mundo/CharSpawn
@onready var waypoint_01: Node3D = $Mundo/Waypoint01
@onready var sfx_stream_player: AudioStreamPlayer = $SFXStreamPlayer

const ESCRIBIR_4 = preload("res://Sounds/SFX/Escribir Libreta (Notas)/Escribir 4.wav")

signal map_ready

var player
var player_sent_w01 = false

func _ready() -> void:
	camera_3d.make_current()
	# ver o revisar si necesitamos fadein en el sonido
	# print("Region map: ", NavigationServer3D.region_get_map($NavigationRegion3D.get_rid()))
	audio_stream_player.play()
	SceneManagerMap03.registered_interaction.connect(_on_registered_interaction)
	process_mode = Node.PROCESS_MODE_INHERIT
	player = get_tree().get_first_node_in_group("Player")
	if player and player.global_position != char_spawn.global_position:
		player.global_position = char_spawn.global_position
	for interactable in get_tree().get_nodes_in_group("Interactable"):
		SceneManagerMap03.set_interactable(interactable)
	emit_signal("map_ready")
	SceneManagerMap03._get_interactables_names()
	print("Mapa listo!")

func _process(_delta: float) -> void:
	# print(SceneManagerMap01._get_interactables())
	# print("Stream line: ", audio_stream_player.get_playback_position())
	if player and player_sent_w01 == false:
		player.set_target_position(waypoint_01.global_position)
		player.trigger_dialogue(3, 5.4)
		player.should_run = true
		player_sent_w01 = true

func _update_item_list() -> void:
	for i in range(item_list.item_count):
		var interactable = item_list.get_item_text(i)
		if SceneManagerMap03._already_interacted(interactable):
			item_list.set_item_disabled(i, true)
		else:
			item_list.set_item_disabled(i, false)

# Corregir que actualicen al manager del mapa correcto
func _on_registered_interaction(interactable_name : String) -> void:
	_play_sfx(ESCRIBIR_4)
	if SceneManagerMap03._get_show_all_interacts():
		item_list.clear()
		for interactable in SceneManagerMap03._get_interactables_names():
			item_list.add_item(interactable)
	else:
		item_list.add_item(interactable_name)
	_update_item_list()

func _play_sfx(sfx : Resource) -> void:
	sfx_stream_player.stream = sfx
	sfx_stream_player.play()
