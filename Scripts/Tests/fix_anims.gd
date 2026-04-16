@tool
extends EditorScript

func _run():
	var root = EditorInterface.get_edited_scene_root()
	print("Raíz de escena: ", root.name)
	
	var anim_player = root.find_child("AnimationPlayer", true, true)
	
	if not anim_player:
		print("ERROR: No se encontró AnimationPlayer")
		return
	
	print(anim_player)
	print("AnimationPlayer encontrado: ", anim_player.get_path())
	
	for lib_name in anim_player.get_animation_library_list():
		var library = anim_player.get_animation_library(lib_name)
		
		for anim_name in library.get_animation_list():
			var anim = library.get_animation(anim_name)
			
			for i in anim.get_track_count():
				var path = str(anim.track_get_path(i))
				
				if path.begins_with("Armature/Skeleton3D"):
					var new_path = path.replace("Armature/Skeleton3D", "Skeleton3D")
					anim.track_set_path(i, new_path)
					print("Corregido [", anim_name, "]: ", path, " → ", new_path)
	
	print("=== Listo! ===")
