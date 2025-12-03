extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("tween_up_down")
	await get_tree().create_timer(.975).timeout
	queue_free()
