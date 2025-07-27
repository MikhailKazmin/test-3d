extends Node3D
class_name PentagramDrawer

@export var material: Material
@export var points_count: int = 64
@export var mesh_instance: MeshInstance3D

func draw_circle(center: Vector3, radius: float) -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINE_STRIP)
	if material:
		st.set_material(material)

	var space_state = get_world_3d().direct_space_state

	for i in points_count + 1:
		var angle = TAU * float(i) / points_count
		var x = center.x + radius * cos(angle)
		var z = center.z + radius * sin(angle)
		var point = Vector3(x, center.y + 50.0, z)
		var query = PhysicsRayQueryParameters3D.create(point, point - Vector3(0, 300, 0))
		var result = space_state.intersect_ray(query)
		st.add_vertex(result.position if result else Vector3(x, center.y, z))

	var mesh = st.commit()
	if mesh_instance:
		mesh_instance.mesh = mesh
