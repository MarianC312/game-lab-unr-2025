extends Node3D

func _ready():
	var multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = 210  # 35 árboles × 6 sprites
	
	# Configura el mesh base (usa el mismo para todos)
	var mesh_sprite = load("res://path/to/your/sprite_mesh.tres")
	multimesh.mesh = mesh_sprite
	
	# Instancia cada sprite con su transformación
	var instance_idx = 0
	for arboleda in get_node("Arboleda").get_children():
		for sprite in arboleda.get_children():
			var transform = sprite.global_transform
			multimesh.set_instance_transform(instance_idx, transform)
			instance_idx += 1
	
	# Crea un nodo para renderizar el multimesh
	var mmi = MultiMeshInstance3D.new()
	mmi.multimesh = multimesh
	add_child(mmi)
	
	# Oculta los Sprite3D originales
	get_node("Arboleda").visible = false
