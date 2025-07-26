extends BaseAttack
class_name PlayerAttack

@onready var crosshair: TextureRect = $"../../../CanvasLayer/HUD/Crosshair"
@export var hand_marker: Marker3D
@export var projectile_scene: PackedScene
var is_attacking := false

var input: PlayerInput
var camera: PlayerCamera

@export var points_count: int = 64
@export var material: Material
@export var pentagram_texture: Texture2D  # Текстура пентаграммы

var drawing_circle := false
var circle_center: Vector3 = Vector3.ZERO
var circle_y: float = 0.0
var circle_radius: float = 5.0
var circle_radius_min: float = 5.0
var circle_radius_max: float = 30.0
var timer_time: float = 3.0
var pentagram_instance: Decal = null  # Для хранения экземпляра пентаграммы
var pentagram_timer: Timer = null  # Таймер для исчезновения пентаграммы

func init(_entity: Node) -> void:
	super.init(_entity)
	crosshair.visible = false
	# Инициализация таймера
	pentagram_timer = Timer.new()
	pentagram_timer.one_shot = true
	pentagram_timer.connect("timeout", Callable(self, "_on_pentagram_timer_timeout"))
	add_child(pentagram_timer)

func _setup():
	input = entity.get_component(PlayerInput)
	camera = entity.get_component(PlayerCamera)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			var ray = get_crosshair_raycast_on_plane()
			if ray != null:
				drawing_circle = true
				circle_center = ray
				circle_y = ray.y
				_draw_circle_on_terrain(circle_center, circle_radius)
		else:
			drawing_circle = false
			if entity.mesh_instance:
				entity.mesh_instance.mesh = null
			# Создание пентаграммы после отжатия ПКМ
			if circle_center != Vector3.ZERO and pentagram_texture:
				_create_pentagram(circle_center, circle_radius)
				pentagram_timer.start(timer_time)  # Устанавливаем таймер на 3 секунды

func process(delta: float) -> void:
	if not is_active:
		return
	if is_attacking:
		spawn_projectile()
		input.consume_attack()
		is_attacking = false
	if input.aim_pressed:
		crosshair.visible = true
		if drawing_circle:
			var crosshair_ray = get_crosshair_raycast_on_plane()
			if crosshair_ray != null:
				var distance = Vector2(crosshair_ray.x - circle_center.x, crosshair_ray.z - circle_center.z).length()
				circle_radius = clamp(distance, circle_radius_min, circle_radius_max)
				_draw_circle_on_terrain(circle_center, circle_radius)
	else:
		crosshair.visible = false
		if entity.mesh_instance:
			entity.mesh_instance.mesh = null

func spawn_projectile():
	if not projectile_scene:
		push_warning("Нет сцены снаряда!")
		return

	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_transform.origin = hand_marker.global_transform.origin

	var crosshair_pos: Vector2 = crosshair.get_global_transform().origin + crosshair.size / 2
	var from = camera.camera.project_ray_origin(crosshair_pos)
	var to = from + camera.camera.project_ray_normal(crosshair_pos) * 1000.0

	var space_state = entity.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	var target_point: Vector3 = result.position if result else to

	var direction = (target_point - hand_marker.global_transform.origin).normalized()
	if projectile.has_method("launch"):
		projectile.launch(direction)
	else:
		push_warning("Префаб не имеет метода launch()!")

func get_crosshair_raycast_on_plane() -> Vector3:
	var crosshair_screen_pos = crosshair.get_global_transform().origin + crosshair.size / 2
	var from = camera.camera.project_ray_origin(crosshair_screen_pos)
	var to = from + camera.camera.project_ray_normal(crosshair_screen_pos) * 1000.0

	var plane_y = get_floor_y()
	var result = ray_intersect_plane(from, to, plane_y)
	return result

func get_mouse_ground_on_circle_plane() -> Vector3:
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.camera.project_ray_origin(mouse_pos)
	var to = from + camera.camera.project_ray_normal(mouse_pos) * 1000.0

	var result = ray_intersect_plane(from, to, circle_y)
	return result

func ray_intersect_plane(from: Vector3, to: Vector3, plane_y: float) -> Vector3:
	var dir = to - from
	if abs(dir.y) < 0.0001:
		return Vector3.ZERO
	var t = (plane_y - from.y) / dir.y
	if t < 0 or t > 1:
		return Vector3.ZERO
	return from + dir * t

func get_floor_y() -> float:
	return 0.0

func _draw_circle_on_terrain(center: Vector3, radius: float):
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINE_STRIP)
	if material:
		st.set_material(material)
	
	var space_state = entity.get_world_3d().direct_space_state
	
	for i in points_count + 1:
		var angle = TAU * float(i) / points_count
		var x = center.x + radius * cos(angle)
		var z = center.z + radius * sin(angle)
		var point = Vector3(x, center.y + 50.0, z)
		var query = PhysicsRayQueryParameters3D.create(point, point - Vector3(0, 300.0, 0))
		query.exclude = [self, entity]
		var result = space_state.intersect_ray(query)
		if result:
			st.add_vertex(result.position)
		else:
			st.add_vertex(Vector3(x, center.y, z))
	
	var mesh = st.commit()
	if entity.mesh_instance:
		entity.mesh_instance.mesh = mesh


# Функция для создания пентаграммы как текстуры
func _create_pentagram(center: Vector3, radius: float):
	if pentagram_instance:
		pentagram_instance.queue_free()
	
	if not pentagram_texture:
		push_warning("Текстура пентаграммы не задана!")
		return
	
	pentagram_instance = Decal.new()
	pentagram_instance.texture_albedo = pentagram_texture
	
	# Устанавливаем размер декала на основе радиуса (диаметр = 2 * radius)
	# Предполагаем, что текстура квадратная, чтобы сохранить пропорции
	var diameter = radius * 2
	pentagram_instance.size = Vector3(diameter, 1.0, diameter)  # Квадратный декал
	
	# Корректируем позицию для наложения на пол
	var ray_origin = Vector3(center.x, center.y + 100.0, center.z)
	var ray_query = PhysicsRayQueryParameters3D.create(ray_origin, ray_origin - Vector3(0, 200.0, 0))
	ray_query.exclude = [self, entity]
	var result = entity.get_world_3d().direct_space_state.intersect_ray(ray_query)
	var surface_y = result.position.y if result else center.y
	
	get_tree().current_scene.add_child(pentagram_instance)
	pentagram_instance.global_transform.origin = Vector3(center.x, surface_y - 0.1, center.z)
	

# Функция для удаления пентаграммы по таймеру
func _on_pentagram_timer_timeout():
	if pentagram_instance:
		pentagram_instance.queue_free()
		pentagram_instance = null
	
	# Поиск объектов с class_name "Corpse" в области пентаграммы
	var corpses = get_tree().get_nodes_in_group("Corpses")
	var corpses_to_process = []
	
	# Собираем трупы в области действия
	for corpse in corpses:
		if corpse is Node3D:
			var distance = circle_center.distance_to(corpse.global_transform.origin)
			if distance <= circle_radius:
				corpses_to_process.append(corpse)
	
	# Анимация опускания всех трупов
	if not corpses_to_process.is_empty():
		var tween_down = create_tween()
		#for corpse in corpses_to_process:
		#	tween_down.tween_property(corpse, "position:y", corpse.position.y - 2.0, 1.0)
		#await tween_down.finished
		
		for i in corpses_to_process.size():
			var corpse = corpses_to_process[i]
			tween_down = tween_down.parallel()
			tween_down.tween_property(corpse, "position:y", corpse.position.y - 2.0, 1.0)
		await tween_down.finished
		for corpse in corpses_to_process:
			if corpse.has_method("get_new_prefab"):
				var new_prefab_scene: PackedScene = corpse.get_new_prefab() 
				var new_instance = new_prefab_scene.instantiate()
				new_instance.position = Vector3(
					corpse.global_transform.origin.x, 
					corpse.global_transform.origin.y, 
					corpse.global_transform.origin.z
				)
				get_tree().current_scene.add_child(new_instance)

		# Удаляем все трупы после завершения анимаций
		for corpse in corpses_to_process:
			corpse.queue_free()
