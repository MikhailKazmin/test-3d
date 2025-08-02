extends BaseComponent
class_name GatherableComponent

# Основные параметры
var is_depleted: bool = false          # Истощён ли ресурс
var is_marked: bool = false            # Помечен ли пентаграммой
var mark: Node3D = null                # Ссылка на визуальный маркер (если есть)

func reset():
	# Для ресурса
	is_depleted = false
	is_marked = false
	mark = null
