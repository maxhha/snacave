extends Control

func _process(delta):
	
	if is_instance_valid(global.apple) and is_instance_valid(global.snake):
		var d = global.apple.global_position - global.snake.get_node('head').global_position
		var s = get_viewport_rect().size / 2
		s = max(s.x, s.y)
		if d.length() > s:
			$arrow.show()
			$arrow.position = $arrow.position.length() * d.normalized()
			$arrow.rotation = d.angle()
		else:
			$arrow.hide()