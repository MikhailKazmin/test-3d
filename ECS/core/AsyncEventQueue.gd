extends Node
class_name AsyncEventQueue

var queue: Array = []

func add_async(callback: Callable, delay: float = 0.0, args: Array = []):
	var entry = {
		"callback": callback,
		"delay": delay,
		"timer": delay,
		"args": args
	}
	queue.append(entry)


func _process(delta):
	var i = 0
	while i < queue.size():
		var entry = queue[i]
		entry["timer"] -= delta
		if entry["timer"] <= 0:
			entry["callback"].callv(entry["args"])
			queue.remove_at(i)
		else:
			i += 1
