extends Node3D
class_name Env

signal update_nav

var last_bake_time: int = 0
var bake_pending: bool = false
@onready var nav_reg: NavigationRegion3D = $"."

func _ready() -> void:
	update_nav.connect(_rebake_navmesh_async)
	
func _rebake_navmesh_async():
	var current_time = Time.get_ticks_msec()
	if current_time - last_bake_time >= 5000:
		_perform_bake()
	else:
		if not bake_pending:
			bake_pending = true
			var remaining = 5000 - (current_time - last_bake_time)
			await get_tree().create_timer(remaining / 1000.0).timeout
			_perform_bake()
			bake_pending = false

func _perform_bake():
	last_bake_time = Time.get_ticks_msec()
	if nav_reg:
		nav_reg.bake_navigation_mesh(true)  # Асинхронно
	else:
		print("NavigationRegion3D не найден")
