@tool
extends Node3D

## ============================================================
##  ARBOLEDA - Spawner de MeshInstance3D con meshes aleatorios
##  Adjuntá este script a un Node3D vacío
## ============================================================

@export_group("Meshes")
## Arrastrá acá los 6 archivos .tres de tus QuadMesh
@export var tree_meshes: Array[Mesh] = []:
	set(v):
		tree_meshes = v
		if Engine.is_editor_hint(): _generate()

@export_group("Distribución")
@export var tree_count: int = 204:
	set(v):
		tree_count = v
		if Engine.is_editor_hint(): _generate()

@export var area_size: Vector2 = Vector2(100.0, 100.0):
	set(v):
		area_size = v
		if Engine.is_editor_hint(): _generate()

@export var area_offset: Vector2 = Vector2(0.0, 0.0):
	set(v):
		area_offset = v
		if Engine.is_editor_hint(): _generate()

@export var random_seed: int = 42:
	set(v):
		random_seed = v
		if Engine.is_editor_hint(): _generate()

@export_group("Escala")
@export var scale_min: float = 0.8:
	set(v):
		scale_min = v
		if Engine.is_editor_hint(): _generate()

@export var scale_max: float = 1.3:
	set(v):
		scale_max = v
		if Engine.is_editor_hint(): _generate()

@export var uniform_scale: bool = true:
	set(v):
		uniform_scale = v
		if Engine.is_editor_hint(): _generate()

@export_group("Rotación")
@export var random_rotation_y: bool = true:
	set(v):
		random_rotation_y = v
		if Engine.is_editor_hint(): _generate()

@export var snap_rotation_90: bool = false:
	set(v):
		snap_rotation_90 = v
		if Engine.is_editor_hint(): _generate()

@export_group("Altura")
@export var y_offset: float = 0.0:
	set(v):
		y_offset = v
		if Engine.is_editor_hint(): _generate()

@export var y_random_range: float = 0.0:
	set(v):
		y_random_range = v
		if Engine.is_editor_hint(): _generate()

@export_group("Zona de exclusión")
## Radio de exclusión (X = eje X del mundo, Y de este Vector2 = eje Z del mundo)
@export var exclusion_radius: float = 0.0:
	set(v):
		exclusion_radius = v
		if Engine.is_editor_hint(): _generate()

@export var exclusion_offset: Vector2 = Vector2(0.0, 0.0):
	set(v):
		exclusion_offset = v
		if Engine.is_editor_hint(): _generate()

@export_group("Depth Sorting")
## Ordenar de atrás hacia adelante por Z (cámara fija mirando en X)
@export var sort_by_z: bool = true:
	set(v):
		sort_by_z = v
		if Engine.is_editor_hint(): _generate()

@export var sort_invert: bool = false:
	set(v):
		sort_invert = v
		if Engine.is_editor_hint(): _generate()

@export_group("Herramientas")
@export var regenerate: bool = false:
	set(v):
		if v: _generate()
		regenerate = false

@export var clear_trees: bool = false:
	set(v):
		if v: _clear()
		clear_trees = false


# ============================================================
func _ready() -> void:
	if not Engine.is_editor_hint():
		_generate()


func _clear() -> void:
	for child in get_children():
		if Engine.is_editor_hint():
			child.free()
		else:
			child.queue_free()


func _generate() -> void:
	if tree_meshes.is_empty():
		push_warning("Arboleda: asigná al menos un Mesh en 'Tree Meshes'.")
		return

	for child in get_children():
		if Engine.is_editor_hint():
			child.free()
		else:
			child.queue_free()

	var rng := RandomNumberGenerator.new()
	rng.seed = random_seed

	var tree_data: Array = []
	var attempts := 0
	var max_attempts := tree_count * 20

	while tree_data.size() < tree_count and attempts < max_attempts:
		attempts += 1

		var x := rng.randf_range(-area_size.x * 0.5, area_size.x * 0.5) + area_offset.x
		var z := rng.randf_range(-area_size.y * 0.5, area_size.y * 0.5) + area_offset.y

		if exclusion_radius > 0.0 and Vector2(x - exclusion_offset.x, z - exclusion_offset.y).length() < exclusion_radius:
			continue

		var y := y_offset + rng.randf_range(-y_random_range * 0.5, y_random_range * 0.5)

		var sx: float
		var sy: float
		var sz: float
		if uniform_scale:
			sx = rng.randf_range(scale_min, scale_max)
			sy = sx
			sz = sx
		else:
			sx = rng.randf_range(scale_min, scale_max)
			sy = rng.randf_range(scale_min, scale_max)
			sz = rng.randf_range(scale_min, scale_max)

		var rot_y := 0.0
		if random_rotation_y:
			if snap_rotation_90:
				rot_y = float(rng.randi() % 4) * PI * 0.5
			else:
				rot_y = rng.randf_range(0.0, TAU)

		var mesh_index := rng.randi() % tree_meshes.size()

		tree_data.append({
			"pos": Vector3(x, y, z),
			"scale": Vector3(sx, sy, sz),
			"rot_y": rot_y,
			"mesh_index": mesh_index,
			"z": z
		})

	if sort_by_z:
		if sort_invert:
			tree_data.sort_custom(func(a, b): return a["z"] < b["z"])
		else:
			tree_data.sort_custom(func(a, b): return a["z"] > b["z"])

	for i in tree_data.size():
		var d = tree_data[i]
		var mi := MeshInstance3D.new()
		mi.mesh = tree_meshes[d["mesh_index"]]
		mi.name = "Tree_%d" % i

		var t := Transform3D()
		t = t.scaled(d["scale"])
		t = t.rotated(Vector3.UP, d["rot_y"])
		t.origin = d["pos"]
		mi.transform = t

		# Usar el material del mesh y asignar render_priority único por árbol
		var mesh := tree_meshes[d["mesh_index"]]
		if mesh.get_surface_count() > 0:
			var src_mat := mesh.surface_get_material(0)
			if src_mat != null:
				var mat := src_mat.duplicate()
				var p := int(float(i) / float(tree_data.size()) * 127.0)
				mat.render_priority = p
				mi.set_surface_override_material(0, mat)
			else:
				push_warning("Arboleda: el mesh en slot %d no tiene material. Asignale un material al QuadMesh antes de guardarlo como .tres" % d["mesh_index"])

		add_child(mi)
		if Engine.is_editor_hint():
			mi.owner = get_tree().edited_scene_root

	if tree_data.size() < tree_count and Engine.is_editor_hint():
		push_warning("Arboleda: solo se colocaron %d/%d árboles." % [tree_data.size(), tree_count])
