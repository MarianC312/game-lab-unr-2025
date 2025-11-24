extends Node

@onready var bg_color: ColorRect = $CanvasLayer50/BGColor
@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal fade_complete

func _ready() -> void:
	bg_color.hide()

func fade_in() -> void:
	bg_color.show()
	animation_player.play("fade_in")
	
	await animation_player.animation_finished
	
	bg_color.hide()
	fade_complete.emit()

func fade_out() -> void:
	bg_color.show()
	animation_player.play_backwards("fade_in")
	
	await animation_player.animation_finished
	
	bg_color.hide()
	fade_complete.emit()
