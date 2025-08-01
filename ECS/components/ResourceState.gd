extends BaseComponent
class_name ResourceStateComponent

@export var is_depleted: bool = false    # true если ресурс закончился
@export var is_marked: bool = false      # true если помечен для сбора
@export var mark: Texture = null          # ссылка на маркер (отдельный объект, иконка)

func reset():
	is_depleted = false    # true если ресурс закончился
	is_marked = false      # true если помечен для сбора
	mark = null          # ссылка на маркер (отдельный объект, иконка)
