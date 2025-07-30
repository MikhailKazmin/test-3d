# ecs/EventBus.gd 
extends Node
class_name EventBus

var handlers: Dictionary = {}  # String -> Array[Callable]

func emit(event_name: String, args: Array = []):
	if handlers.has(event_name):
		print("EventBus.emit.event_name - ",event_name)
		for handler in handlers[event_name]:
			handler.callv(args)

func subscribe(event_name: String, handler: Callable):
	if not handlers.has(event_name):
		print("EventBus.subscribe.event_name - ",event_name," EventBus.subscribe.handler - ",handler)
		handlers[event_name] = []
	handlers[event_name].append(handler)

func unsubscribe(event_name: String, handler: Callable):
	
	if handlers.has(event_name):
		print("EventBus.unsubscribe.event_name - ",event_name," EventBus.unsubscribe.handler - ",handler)
		handlers[event_name].erase(handler)
