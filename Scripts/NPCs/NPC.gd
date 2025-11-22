extends CharacterBody3D

@export var npc_name : String = ""
@export var dialogue : DialogueResource = preload("res://Dialogues/Default/Default.dialogue")
@onready var animation_player : AnimationPlayer = $npcmodel/Prototype/NPC/Armature/AnimationPlayer

var is_dialogue_active : bool = false

enum AnimationState {IDLE, WALKING, RUNNING, TALKING}
var play_animation_state : AnimationState = AnimationState.IDLE

func _ready() -> void:
	DialogueManager.dialogue_started.connect(_on_dialogue_start)
	DialogueManager.dialogue_ended.connect(_on_dialogue_end)

func _physics_process(_delta: float) -> void:
	match play_animation_state:
		AnimationState.IDLE:
			animation_player.play("IdleNeutral")
		AnimationState.WALKING:
			animation_player.play("Walk")
		AnimationState.TALKING:
			animation_player.play("Talk4")
		AnimationState.RUNNING:
			animation_player.play("Run2")
			

func interact() -> void:
	print("Interacted with: ", npc_name)
	
	DialogueManager.show_dialogue_balloon(dialogue, "start", [npc_name])

func _on_dialogue_start(_dialogue) -> void:
	play_animation_state = AnimationState.TALKING
	is_dialogue_active = true

func _on_dialogue_end(_dialogue) -> void:
	play_animation_state = AnimationState.IDLE
	await get_tree().create_timer(0.2).timeout
	is_dialogue_active = false
