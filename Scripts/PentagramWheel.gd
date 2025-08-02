# PentagramWheel.gd (Новый скрипт, прикрепите к Control или CanvasLayer)
extends Control
class_name PentagramWheel

@export var radius: float = 150.0  # Радиус колеса
@export var icon_size: Vector2 = Vector2(64, 64)  # Размер иконок
@export var highlight_scale: float = 1.2  # Масштаб подсветки

var effects: Array[PentagramEffect] = []  # Массив доступных эффектов
var icon_nodes: Array[TextureRect] = []
var highlighted_index: int = -1
var center: Vector2

func _ready() -> void:
	# Растягиваем Control на весь экран
	anchors_preset = Control.PRESET_FULL_RECT
	size = get_viewport_rect().size

	# Динамический расчет радиуса
	radius = min(size.x, size.y) * 0.3  # 30% от меньшей стороны экрана

	visible = false
	center = get_viewport_rect().size / 2
	_create_icons()

func _draw() -> void:
	if not visible:
		return
	# Рисуем круг колеса
	draw_circle(center, radius, Color(1, 1, 1, 0.2))  # Полупрозрачный круг
	# Рисуем центральную точку
	draw_circle(center, 5, Color(1, 0, 0, 1.0))  # Красная точка в центре

func _create_icons() -> void:
	for child in get_children():
		if child is TextureRect:
			child.queue_free()
	icon_nodes.clear()
	
	var num_effects = effects.size()
	for i in num_effects:
		var angle = 2 * PI * i / num_effects + PI / 2  # Смещение для старта сверху
		var pos = Vector2(radius * cos(angle), -radius * sin(angle))
		
		# Добавляем смещение относительно центра Control
		var icon = TextureRect.new()
		icon.texture = effects[i].texture_wheel
		icon.size = icon_size
		icon.position = center + pos - icon_size / 2  # Позиция относительно центра
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		add_child(icon)
		icon_nodes.append(icon)

func update_highlight(mouse_pos: Vector2) -> void:
	var dir = mouse_pos - center
	var dist = dir.length()
	if dist < radius / 2:  # Если слишком близко к центру, нет подсветки
		_set_highlighted(-1)
		return
	
	var angle = atan2(-dir.y, dir.x)
	if angle < 0:
		angle += 2 * PI
	
	var num_effects = effects.size()
	var sector_size = 2 * PI / num_effects
	var index = floor(angle / sector_size)
	
	_set_highlighted(index)

func _set_highlighted(index: int) -> void:
	if highlighted_index == index:
		return
	
	if highlighted_index != -1 and highlighted_index < icon_nodes.size():
		icon_nodes[highlighted_index].scale = Vector2(1.0, 1.0)
		# Опционально: изменить modulation или другой эффект
	
	highlighted_index = index
	
	if highlighted_index != -1 and highlighted_index < icon_nodes.size():
		icon_nodes[highlighted_index].scale = Vector2(highlight_scale, highlight_scale)
		# Опционально: изменить modulation на яркий цвет

func get_selected_effect() -> PentagramEffect:
	if highlighted_index == -1:
		return null
	print("Selected pentagram: " + effects[highlighted_index].name)
	return effects[highlighted_index]

func center_on_screen() -> void:
	center = get_viewport_rect().size / 2
	position = center - size / 2  # Центрируем Control
