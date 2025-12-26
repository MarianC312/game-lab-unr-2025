extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pivot: Node2D = $BoxContainer/Pivot

@export var mouse_sens := 0.00075
@export var max_angle := 180

signal completed(success : bool)

var is_locked := true
var unlock_spot := randf_range(0.2, 0.8)
var pick_position := 0.5

func _ready() -> void:
	animation_player.play("slide_panels")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	await animation_player.animation_finished
	pivot.show()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_locked:
		pick_position += event.relative.x * mouse_sens
		pick_position = clamp(pick_position, 0.0, 1.0)
	
	if event.is_action_pressed("left_click") and is_locked and pivot.is_visible_in_tree():
		try_unlock()
	
	if event.is_action_pressed("right_click"):
		quit_minigame()

func _process(_delta: float) -> void:
	# print(pick_position)
	var angle = lerp(0, max_angle, pick_position)
	pivot.rotation = deg_to_rad(angle)

func try_unlock():
	if abs(pick_position - unlock_spot) < 0.05:
		is_locked = false
		animation_player.play("unlock")
		await animation_player.animation_finished
		emit_signal("completed", true)
		print("desbloqueado!")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		# queue_free()
	else:
		# vibración, sonido, feedback
		shake_pick()
		print("falló")

func shake_pick(intensity := 5.0, duration := 0.1) -> void:
	var tween := create_tween()
	var original_pos: Vector2 = pivot.position
	
	var step := tween.tween_property(pivot, "position", original_pos + Vector2(randf_range(-intensity, intensity), 0), duration / 2)
	step.set_trans(Tween.TRANS_SINE)

	tween.tween_property(pivot, "position", original_pos, duration / 2)

func quit_minigame() -> void:
		animation_player.play_backwards("slide_panels")
		await animation_player.animation_finished
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		queue_free()
