@tool
extends MultiMeshInstance3D
@export var distribute : bool = false : set = _on_distribute
@export var area_center : Vector3 = Vector3(0, 0.0, 0.0)
@export var area_size : Vector3 = Vector3(100.0, 0.0, 100.0)
@export var y_offset : float = 1.0
@export var min_scale : float = 0.3
@export var max_scale : float = 0.7
@export var use_seed : bool = true
@export var random_seed : int = 43

func _on_distribute(_val: bool):
	distribute = false
	if not multimesh:
		push_error("No hay MultiMesh asignado")
		return
	if multimesh.instance_count == 0:
		push_error("Instance Count es 0")
		return

	print("Distribuyendo ", multimesh.instance_count, " instancias...")

	var rng = RandomNumberGenerator.new()
	if use_seed:
		rng.seed = random_seed

	for i in multimesh.instance_count:
		var x = area_center.x + rng.randf_range(-area_size.x * 0.5, area_size.x * 0.5)
		var z = area_center.z + rng.randf_range(-area_size.z * 0.5, area_size.z * 0.5)

		var scale_val = rng.randf_range(min_scale, max_scale)
		var rot_y = rng.randf_range(0.0, TAU)

		var t = Transform3D()
		t = t.rotated(Vector3.UP, rot_y)
		t = t.scaled(Vector3(scale_val, scale_val, scale_val))
		t.origin = Vector3(x, y_offset, z)

		multimesh.set_instance_transform(i, t)

	print("Listo!")
