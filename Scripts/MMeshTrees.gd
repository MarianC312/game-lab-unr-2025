@tool
extends Node3D

@export_group("Meshes")
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
@export var exclusion_radius: float = 0.0:
	set(v):
		exclusion_radius = v
		if Engine.is_editor_hint(): _generate()

@export var exclusion_offset: Vector2 = Vector2(0.0, 0.0):
	set(v):
		exclusion_offset = v
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

	_clear()

	var rng := RandomNumberGenerator.new()
	rng.seed = random_seed

	var mesh_count := tree_meshes.size()

	# Distribuir tree_count equitativamente entre los meshes.
	# Si no divide exacto, los sobrantes se reparten uno a uno
	# desde el primer mesh (ej: 151 árboles / 6 meshes = 25,25,25,25,25,26)
	var base_per_mesh := tree_count / mesh_count
	var remainder := tree_count % mesh_count

	var counts: Array[int] = []
	for i in mesh_count:
		counts.append(base_per_mesh + (1 if i < remainder else 0))

	for mesh_index in mesh_count:
		var target := counts[mesh_index]

		var transforms: Array[Transform3D] = []
		var placed := 0
		var attempts := 0
		var max_attempts := target * 20

		while placed < target and attempts < max_attempts:
			attempts += 1

			var x := rng.randf_range(-area_size.x * 0.5, area_size.x * 0.5) + area_offset.x
			var z := rng.randf_range(-area_size.y * 0.5, area_size.y * 0.5) + area_offset.y

			if exclusion_radius > 0.0 and Vector2(x - exclusion_offset.x, z - exclusion_offset.y).length() < exclusion_radius:
				continue

			var y := y_offset + rng.randf_range(-y_random_range * 0.5, y_random_range * 0.5)

			var s: Vector3
			if uniform_scale:
				var sv := rng.randf_range(scale_min, scale_max)
				s = Vector3(sv, sv, sv)
			else:
				s = Vector3(
					rng.randf_range(scale_min, scale_max),
					rng.randf_range(scale_min, scale_max),
					rng.randf_range(scale_min, scale_max)
				)

			var rot_y := 0.0
			if random_rotation_y:
				rot_y = snappedf(rng.randf_range(0.0, TAU), PI * 0.5) if snap_rotation_90 else rng.randf_range(0.0, TAU)

			var t := Transform3D()
			t = t.scaled(s)
			t = t.rotated(Vector3.UP, rot_y)
			t.origin = Vector3(x, y, z)

			transforms.append(t)
			placed += 1

		if transforms.is_empty():
			continue

		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = tree_meshes[mesh_index]
		mm.instance_count = transforms.size()
		for i in transforms.size():
			mm.set_instance_transform(i, transforms[i])

		var mmi := MultiMeshInstance3D.new()
		mmi.multimesh = mm
		mmi.name = "Trees_Mesh%d" % mesh_index
		mmi.lod_bias = 0.05
		add_child(mmi)

		if Engine.is_editor_hint():
			mmi.owner = get_tree().edited_scene_root

		if placed < target and Engine.is_editor_hint():
			push_warning("Arboleda [Mesh %d]: solo se colocaron %d/%d árboles." % [mesh_index, placed, target])

	set_physics_process(false)
