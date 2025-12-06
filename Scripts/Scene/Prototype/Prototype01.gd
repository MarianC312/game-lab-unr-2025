extends Node3D

@onready var item_list: ItemList = $UI/CanvasLayer15/ItemList
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

signal map_ready

func _ready() -> void:
	# ver o revisar si necesitamos fadein en el sonido
	# print("Region map: ", NavigationServer3D.region_get_map($NavigationRegion3D.get_rid()))
	audio_stream_player.play()
	SceneManagerMap01.registered_interaction.connect(_on_registered_interaction)
	process_mode = Node.PROCESS_MODE_INHERIT
	emit_signal("map_ready")
	print("Mapa listo!")

func _process(_delta: float) -> void:
	# print(SceneManagerMap01._get_interactables())
	# print("Stream line: ", audio_stream_player.get_playback_position())
	pass

func _update_item_list() -> void:
	for i in range(item_list.item_count):
		var interactable = item_list.get_item_text(i)
		if SceneManagerMap01._already_interacted(interactable):
			item_list.set_item_disabled(i, true)
		else:
			item_list.set_item_disabled(i, false)


func _on_registered_interaction(interactable_name : String) -> void:
	if SceneManagerMap01._get_show_all_interacts():
		item_list.clear()
		for interactable in SceneManagerMap01._get_interactables():
			item_list.add_item(interactable)
	else:
		item_list.add_item(interactable_name)
	_update_item_list()
