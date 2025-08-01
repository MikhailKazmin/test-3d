extends BaseComponent
class_name CorpseComponent

@export var prefab: PackedScene  = null # что за юнит был до смерти

func reset():
	prefab = null
