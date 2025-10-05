extends Node3D

@onready var gridmap = $World/FloorGM

func _ready():
	var mesh_lib = MeshLibrary.new()
	var models_path = "res://Models/Prototype/OBJ format/"
	var previews_path = "res://Models/Prototype/Previews/"
	var dir = DirAccess.open(models_path)
	var item_index = 0

	if dir:
		for file_name in dir.get_files():
			if file_name.ends_with(".glb") or file_name.ends_with(".obj") or file_name.ends_with(".fbx"):
				var mesh_path = models_path + file_name
				var mesh_res = load(mesh_path)

				if mesh_res:
					mesh_lib.create_item(item_index)
					mesh_lib.set_item_name(item_index, file_name.get_basename())
					mesh_lib.set_item_mesh(item_index, mesh_res)

					# Crear colisión optimizada
					var shapes = create_optimized_collision(mesh_res)
					if shapes:
						mesh_lib.set_item_shapes(item_index, shapes)

					# Asignar preview si existe
					var preview_path = previews_path + file_name.get_basename() + ".png"
					if FileAccess.file_exists(preview_path):
						var tex = load(preview_path)
						mesh_lib.set_item_preview(item_index, tex)

					item_index += 1

		# Asignar la librería generada al GridMap
		gridmap.mesh_library = mesh_lib
		ResourceSaver.save(mesh_lib, "res://MeshLibraries/generated_lib.tres")
		print("MeshLibrary generada con", item_index, "elementos.")
	else:
		push_error("No se pudo abrir el directorio: " + models_path)


# Función para crear colisiones optimizadas
func create_optimized_collision(mesh : Mesh) -> Array:
	if mesh is ArrayMesh:
		var convex_shape = mesh.create_convex_shape()
		if convex_shape:
			return [convex_shape] # Retorna un array con la colisión
		# Fallback: trimesh collision
		var trimesh_shape = mesh.create_trimesh_shape()
		if trimesh_shape:
			return [trimesh_shape]
	return []
