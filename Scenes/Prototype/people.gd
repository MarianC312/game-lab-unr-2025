extends StaticBody3D

@export var pep_name : String = ""

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	pass

func interact() -> void:
	print("Interacted with me: ", pep_name)
