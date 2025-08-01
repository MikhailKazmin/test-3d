# PentagramWheel.gd
extends Control
class_name PentagramWheel

signal effect_selected(effect_type: String, effect_data: Dictionary)

@export var radius: float = 150.0
@export var icon_size: Vector2 = Vector2(64, 64)
@export var highlight_scale: float = 1.2

var effect_descriptors: Array = []  # Массив словарей [{type, name, texture_wheel, ...}]
var icon_nodes: Array[TextureRect] = []
var highlighted_index: int = -1
var center: Vector2

func _ready() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	size = get_viewport_rect().size
	visible = false
	_update_center()
	_create_icons()

func set_effects(effects: Array) -> void:
	# effects: [{type, name, texture_wheel, ...}]
	effect_descriptors = effects
	_create_icons()
	_draw()

func show_wheel():
	visible = true
	_update_center()
	_create_icons()
	_draw()
	highlighted_index = -1

func hide_wheel():
	visible = false
	if highlighted_index != -1 and highlighted_index < icon_nodes.size():
		icon_nodes[highlighted_index].scale = Vector2(1.0, 1.0)
	highlighted_index = -1

func _update_center():
	center = get_viewport_rect().size / 2
	position = center - size / 2

func _draw() -> void:
	if not visible:
		return
	draw_circle(center, radius, Color(1, 1, 1, 0.18))
	draw_circle(center, 5, Color(1, 0, 0, 0.9))

func _create_icons() -> void:
	for child in get_children():
		if child is TextureRect:
			child.queue_free()
	icon_nodes.clear()
	var num = effect_descriptors.size()
	if num == 0:
		return
	for i in num:
		var angle = 2 * PI * i / num + PI / 2
		var pos = Vector2(radius * cos(angle), -radius * sin(angle))
		var icon = TextureRect.new()
		icon.texture = effect_descriptors[i].texture_wheel
		icon.size = icon_size
		icon.position = center + pos - icon_size / 2
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon.modulate = Color(1, 1, 1, 0.92)
		add_child(icon)
		icon_nodes.append(icon)

func _input(event):
	if not visible:
		return
	if event is InputEventMouseMotion:
		update_highlight(event.position)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if highlighted_index != -1 and highlighted_index < effect_descriptors.size():
			var desc = effect_descriptors[highlighted_index]
			emit_signal("effect_selected", desc.type, desc)
			hide_wheel()
		elif event.button_index == MOUSE_BUTTON_LEFT:
			hide_wheel()  # Клик вне — закрыть колесо

func update_highlight(mouse_pos: Vector2) -> void:
	var dir = mouse_pos - center
	var dist = dir.length()
	if effect_descriptors.size() == 0 or dist < radius / 2:
		_set_highlighted(-1)
		return
	var angle = atan2(-dir.y, dir.x)
	if angle < 0:
		angle += 2 * PI
	var num = effect_descriptors.size()
	var sector_size = 2 * PI / num
	var index = floor(angle / sector_size)
	_set_highlighted(index)

func _set_highlighted(index: int) -> void:
	if highlighted_index == index:
		return
	if highlighted_index != -1 and highlighted_index < icon_nodes.size():
		icon_nodes[highlighted_index].scale = Vector2(1.0, 1.0)
		icon_nodes[highlighted_index].modulate = Color(1, 1, 1, 0.92)
	highlighted_index = index
	if highlighted_index != -1 and highlighted_index < icon_nodes.size():
		icon_nodes[highlighted_index].scale = Vector2(highlight_scale, highlight_scale)
		icon_nodes[highlighted_index].modulate = Color(1.15, 1.15, 1, 1)

func get_selected_effect() -> Dictionary:
	if highlighted_index == -1 or highlighted_index >= effect_descriptors.size():
		return {}
	return effect_descriptors[highlighted_index]

func center_on_screen() -> void:
	_update_center()
	_create_icons()
	_draw()

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		size = get_viewport_rect().size
		radius = min(size.x, size.y) * 0.3
		center_on_screen()
		
