extends Node

@export var target_fps = 60
@export var max_draw_calls = 100

var quality : GraphicsQuality = GraphicsQuality.HIGH

enum GraphicsQuality {
	LOW,
	MEDIUM,
	HIGH
}

func _ready():
	GameManager.restart_game.connect(_on_restart)
	optimize_for_low_end_devices()

func _on_restart() -> void:
	quality = GraphicsQuality.HIGH

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
		
		# Engine.physics_ticks_per_second = 60
		# get_tree().call_group("heavy_objects", "queue_free")
		
		var env = get_tree().root.get_node("WorldEnvironment")
		if env:
			env.environment.ambient_light_energy = 0.8
		
		get_tree().root.msaa_3d = Viewport.MSAA_DISABLED
		# get_tree().call_group("expensive_lights", "queue_free")
		
		var msaa3d = get_tree().root.msaa_3d
		if msaa3d:
			msaa3d = Viewport.MSAA_DISABLED
			msaa3d = Viewport.MSAA_2X
		
	elif memory < 1000000000: 
		print("Optimizando para PC media...")
		# Engine.physics_ticks_per_second = 45
		
	else:
		print("PC potente detectada")
		# Engine.physics_ticks_per_second = 60

func apply_graphics_quality(env: WorldEnvironment):
	var e = env.environment
	
	match quality:
		GraphicsQuality.HIGH:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
			get_viewport().scaling_3d_scale = 1.0
			e.glow_enabled = true
			e.glow_blend_mode = Environment.GLOW_BLEND_MODE_MIX
			e.glow_intensity = e.glow_intensity * 3 if e.glow_intensity < 1 else e.glow_intensity
			e.fog_enabled = true
			e.fog_mode = Environment.FOG_MODE_DEPTH
			e.fog_density = 0.4
			for light in get_tree().get_nodes_in_group("light"):
				light.visible = true
				if light.is_in_group("shadow"):
					light.shadow_enabled = true
					light.layers = 1
			for particle : GPUParticles3D in get_tree().get_nodes_in_group("particle"):
				particle.emitting = true
				particle.amount_ratio = 1
				particle.visible = true
			for shade in get_tree().get_nodes_in_group("hq_only"):
				shade.visible = true
			for mmesh : MultiMeshInstance3D in get_tree().get_nodes_in_group("multimesh"):
				if mmesh.multimesh:
					mmesh.multimesh.visible_instance_count = -1
				else:
					await get_tree().process_frame
					print("Espere un procesamiento de frame, rellamando función...")
					apply_graphics_quality(env)
			print("Graphics set to high.")
		
		GraphicsQuality.MEDIUM:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
			get_viewport().scaling_3d_scale = 0.8
			e.glow_enabled = true
			e.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
			e.glow_intensity = e.glow_intensity * 0.3
			e.fog_enabled = true
			e.fog_density = 0.0275
			for light in get_tree().get_nodes_in_group("light"):
				if light.is_in_group("shadow"):
					light.visible = true
					light.shadow_enabled = true
					light.layers = 1
				else:
					if not light.is_in_group("light_ob"):
						light.visible = false
					else:
						light.visible = true
			for particle : GPUParticles3D in get_tree().get_nodes_in_group("particle"):
				particle.emitting = true
				particle.amount_ratio = 0.35
				particle.visible = true
			for shade in get_tree().get_nodes_in_group("hq_only"):
				shade.visible = false
			for mmesh : MultiMeshInstance3D in get_tree().get_nodes_in_group("multimesh"):
				if mmesh.multimesh:
					mmesh.multimesh.visible_instance_count = roundi(mmesh.multimesh.instance_count * 0.45)
				else:
					await get_tree().process_frame
					print("Espere un procesamiento de frame, rellamando función...")
					apply_graphics_quality(env)
			print("Graphics set to medium.")
		
		GraphicsQuality.LOW:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
			get_viewport().scaling_3d_scale = 0.6
			e.glow_enabled = false
			e.fog_enabled = false
			e.reflected_light_source =Environment.REFLECTION_SOURCE_DISABLED
			for light in get_tree().get_nodes_in_group("light"):
				if light.is_in_group("shadow"):
					light.shadow_enabled = false
					light.layers = 0
				else:
					if not light.is_in_group("light_ob"):
						light.visible = false
					else:
						light.visible = true
			for particle in get_tree().get_nodes_in_group("particle"):
				particle.emitting = false
				particle.visible = false
			for shade in get_tree().get_nodes_in_group("hq_only"):
				shade.visible = false
			for mmesh : MultiMeshInstance3D in get_tree().get_nodes_in_group("multimesh"):
				if mmesh.multimesh:
					mmesh.multimesh.visible_instance_count = roundi(mmesh.multimesh.instance_count * 0.15)
				else:
					await get_tree().process_frame
					print("Espere un procesamiento de frame, rellamando función...")
					apply_graphics_quality(env)
			print("Graphics set to low.")
		
		_:
			print("Calidad gráfica no encontrada!")

func set_graphics_quality(index : GraphicsQuality) -> void:
	quality = index
