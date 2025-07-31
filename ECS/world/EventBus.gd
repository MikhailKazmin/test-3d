# ecs/EventBus.gd 
extends Node
class_name EventBus

var handlers: Dictionary = {}

func emit(event_name: EventBus.Name, args: Array = []):
	if handlers.has(event_name):
		for handler:Callable in handlers[event_name]:
			#print("emit = ",event_name,
				#" - object = ",handler.get_object(),
				#" - method = ",handler.get_method())
			#if args.size() <= 1:
				#result = handler.call(args)
			#else:
			handler.call(args)


func subscribe(event_name: EventBus.Name, handler: Callable):
	#print("subscribe = ",event_name,
		#" - object = ",handler.get_object(),
		#" - method = ",handler.get_method())
	if not handlers.has(event_name):
		handlers[event_name] = []
	handlers[event_name].append(handler)

func unsubscribe(event_name: EventBus.Name, handler: Callable):
	if handlers.has(event_name):
		#print("unsubscribe = ",event_name,
			#" - object = ",handler.get_object(),
			#" - method = ",handler.get_method())
		handlers[event_name].erase(handler)

enum Name
{
	RiseStarted,
	RiseCompleted,
	GatherResource,
	StateChanged,
	SetState,
	ReadyForMovement,
	GatherAnimationFinished
}
