extends Node3D

@onready var fixed_camera_01: Camera3D = $"Camera pivot/FixedCamera01"
@onready var fixed_camera_02: Camera3D = $"Camera pivot/FixedCamera02"


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		fixed_camera_01.make_current()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.get_camera_3d().make_current()


func _on_area_3d_2_body_entered(body: Node3D, id: int) -> void:
	if body.is_in_group("Player") and id == 1:
		fixed_camera_02.make_current()


func _on_area_3d_2_body_exited(body: Node3D, _id: int) -> void:
	if body.is_in_group("Player"):
		body.get_camera_3d().make_current()
