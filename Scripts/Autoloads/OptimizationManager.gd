extends Node

@export var target_fps = 30
@export var max_draw_calls = 100

func _ready():
	optimize_for_low_end_devices()

func _process(_delta):
	if Input.is_action_pressed("ui_accept"):  # Espacio
		print("=== COLLISION SHAPES ===")
		
		var all_collision_shapes = get_tree().get_nodes_in_group("collision_shapes")
		if all_collision_shapes.size() == 0:
			# Si no hay grupo, búscalas todas
			all_collision_shapes = get_tree().get_nodes_in_group("*")
			all_collision_shapes = all_collision_shapes.filter(
				func(node): return node is CollisionShape3D
			)
		
		print("CollisionShape3D encontradas: ", all_collision_shapes.size())
		
		for cs in all_collision_shapes:
			print("  - ", cs.name, " | Tipo: ", cs.shape.get_class())

func optimize_for_low_end_devices():
	var memory = OS.get_static_memory_usage()
	print(memory)
	if memory < 500000000:
		print("Optimizando para PC con pocos recursos...")
		
		Engine.physics_ticks_per_second = 60
		get_tree().call_group("heavy_objects", "queue_free")
		
		var env = get_tree().root.get_node("WorldEnvironment")
		if env:
			env.environment.ambient_light_energy = 0.8
		
		get_tree().root.msaa_3d = Viewport.MSAA_DISABLED
		get_tree().call_group("expensive_lights", "queue_free")
		
		var msaa3d = get_tree().root.msaa_3d
		if msaa3d:
			msaa3d = Viewport.MSAA_DISABLED
			msaa3d = Viewport.MSAA_2X
		
	elif memory < 1000000000: 
		print("Optimizando para PC media...")
		Engine.physics_ticks_per_second = 45
		
	else:
		print("PC potente detectada")
		Engine.physics_ticks_per_second = 60
