extends Sprite

const DESTROY_TIME = 10

signal destroy()

var timer = randf()
var _d = false

func to_destroy():
	_d = true

func _process(delta):
	if _d:
		timer += delta
		frame = frame % (hframes*2) + (2 + int(timer*2 > DESTROY_TIME))*hframes*2
		if timer > DESTROY_TIME:
			emit_signal("destroy")
			queue_free()