extends BaseComponent
class_name GatherableComponent

@export var resource_type: String = "default"  # Например: "wood", "stone"
@export var amount: int = 1                    # Сколько всего ресурсов

func reset():
	resource_type = "default"  # Например: "wood", "stone"
	amount = 1                    # Сколько всего ресурсов
