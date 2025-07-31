extends Node3D
class_name PentagramCaster

@export var mesh_instance: MeshInstance3D
@export var decal_parent: Node3D
@export var drawer: PentagramDrawer
@export var current_effect: PentagramEffect
@export var world: World

var drawing := false
var center: Vector3
var radius: float = 5.0
var decal: Decal
var timer: Timer

func start_cast(position: Vector3) -> void:
	center = position
	drawing = true
	radius = 5.0
	drawer.draw_circle(center, radius)

func update_radius(pos: Vector3) -> void:
	if not drawing: return
	radius = clamp(center.distance_to(pos), 5.0, 30.0)
	drawer.draw_circle(center, radius)

func confirm_cast() -> void:
	if not drawing: return
	drawing = false
	drawer.mesh_instance.mesh = null
	_spawn_decal(center, radius)
	_start_timer()

func _spawn_decal(pos: Vector3, radius: float) -> void:
	if decal:
		decal.queue_free()
	decal = Decal.new()
	decal.texture_albedo = current_effect.texture
	decal.size = Vector3(radius * 2.0, 1.0, radius * 2.0)
	decal.global_position = Vector3(pos.x, _get_floor_y(pos) - 0.1, pos.z)
	decal_parent.add_child(decal)

func _start_timer() -> void:
	if not timer:
		timer = Timer.new()
		timer.one_shot = true
		timer.timeout.connect(_on_cast_timeout)
		add_child(timer)
	timer.start(current_effect.cast_duration)

func _on_cast_timeout() -> void:
	if decal:
		decal.queue_free()
	if current_effect:
		current_effect.apply(center, radius, self, world)

func _get_floor_y(pos: Vector3) -> float:
	var from = pos + Vector3.UP * 100
	var to = pos - Vector3.UP * 100
	var result = get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
	return result.position.y if result else pos.y
