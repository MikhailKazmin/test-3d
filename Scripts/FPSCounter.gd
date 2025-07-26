extends Node
class_name FPSCounter

@export var rich_text_label: RichTextLabel
@export var update_interval: float = 0.5  # Интервал обновления в секундах

var frame_times := []
var frame_count := 0
var last_update_time := 0.0
var min_fps_10s := 1000.0
var min_fps_60s := 1000.0

func _ready():
	if not rich_text_label:
		push_warning("RichTextLabel not assigned!")
		set_process(false)
	else:
		set_process(true)
	last_update_time = Time.get_ticks_msec() / 1000.0

func _process(_delta):
	var current_time = Time.get_ticks_msec() / 1000.0
	frame_count += 1
	
	# Обновляем данные каждые update_interval секунд
	if current_time - last_update_time >= update_interval:
		var fps = frame_count / update_interval
		frame_times.append(fps)
		
		# Ограничиваем историю: последние 10 секунд (20 замеров при 0.5s) и 1 минута (120 замеров)
		while frame_times.size() > 120:  # 1 минута при интервале 0.5s
			frame_times.pop_front()
		
		# Вычисляем статистику
		var avg_10s = _calculate_average(frame_times.slice(max(0, frame_times.size() - 20), frame_times.size()))  # 10 секунд
		var avg_60s = _calculate_average(frame_times)  # 1 минута
		min_fps_10s = _calculate_min(frame_times.slice(max(0, frame_times.size() - 20), frame_times.size()))
		min_fps_60s = _calculate_min(frame_times)
		
		# Обновляем RichTextLabel
		rich_text_label.bbcode_text = "[center]FPS Stats:\n" + \
			"[b]Current:[/b] {current}\n".format({"current": "%.1f" % fps}) + \
			"[b]Avg 10s:[/b] {avg10s}\n".format({"avg10s": "%.1f" % avg_10s}) + \
			"[b]Avg 60s:[/b] {avg60s}\n".format({"avg60s": "%.1f" % avg_60s}) + \
			"[b]Min 10s:[/b] {min10s}\n".format({"min10s": "%.1f" % min_fps_10s}) + \
			"[b]Min 60s:[/b] {min60s}".format({"min60s": "%.1f" % min_fps_60s}) + "[/center]"
		
		frame_count = 0
		last_update_time = current_time

func _calculate_average(arr: Array) -> float:
	if arr.size() == 0:
		return 0.0
	return arr.reduce(func(acc, x): return acc + x, 0.0) / arr.size()

func _calculate_min(arr: Array) -> float:
	if arr.size() == 0:
		return 0.0
	return arr.min()
