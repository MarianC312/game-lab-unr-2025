extends Control

@onready var rich_text_label: RichTextLabel = $Panel/MarginContainer/RichTextLabel
@onready var button: Button = $Panel/MarginContainer2/Button
@onready var animation_player: AnimationPlayer = $Panel/AnimationPlayer

@export var text_alert : String

const ALERT_TIME := 4.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rich_text_label.text = text_alert
	animation_player.play("pop_up")
	await animation_player.animation_finished
	await get_tree().create_timer(ALERT_TIME).timeout
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	animation_player.play_backwards("pop_up")
	await animation_player.animation_finished
	queue_free()
