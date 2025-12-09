extends Node3D

@onready var fixed_camera: Camera3D = $"Camera pivot/FixedCamera"


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		fixed_camera.make_current()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.get_camera_3d().make_current()
