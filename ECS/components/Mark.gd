extends Resource
class_name MarkComponent

@export var mark: Texture = null  # Визуальный маркер, например, MeshInstance3D или Sprite3D

func reset():
	mark = null          # Визуальный маркер, например, MeshInstance3D или Sprite3D
