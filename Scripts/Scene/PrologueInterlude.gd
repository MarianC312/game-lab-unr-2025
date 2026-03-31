extends Control

@export var play_first := true

@export var dialogue : DialogueResource = preload("res://Dialogues/Default/Default.dialogue")
@onready var animation_player_p1: AnimationPlayer = $AnimationPlayerP1
@onready var container_p1: Control = $CanvasLayer20/ContainerP1
@onready var container_p2: Control = $CanvasLayer20/ContainerP2

func _ready() -> void:
	# start_dialogue()
	if play_first:
		_play_first_paragraph()
	else:
		_play_second_paragraph()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		if animation_player_p1.is_playing():
			animation_player_p1.advance(9999)
			animation_player_p1.speed_scale = 100.0

func _play_first_paragraph() -> void:
	await get_tree().create_timer(1).timeout
	container_p1.show()
	animation_player_p1.play("line01")
	animation_player_p1.queue("line02")
	animation_player_p1.queue("line03")
	animation_player_p1.queue("line04")
	animation_player_p1.queue("line05")

func _play_second_paragraph() -> void:
	container_p1.queue_free()
	container_p2.show()
	animation_player_p1.play("line06")
	animation_player_p1.queue("line07")
	animation_player_p1.queue("line08")
	animation_player_p1.queue("line09")
	animation_player_p1.queue("line10")
	animation_player_p1.queue("line11")

func start_dialogue() -> void:
	await get_tree().create_timer(0.75).timeout
	DialogueManager.show_dialogue_balloon(dialogue, "start")

func _on_button_01_pressed() -> void:
	animation_player_p1.speed_scale = 1.0
	animation_player_p1.play("clearparagraph01")
	await animation_player_p1.animation_finished
	_play_second_paragraph()

func _on_button_02_pressed() -> void:
	animation_player_p1.play("clearparagraph02")
	await animation_player_p1.animation_finished
	GameManager.load_new_map("")
