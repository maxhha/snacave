extends "Enemy.gd"

var TIME_TO_ROTATE = 5 + randf() * 10

var rotate_timer = randf()

func logic(delta):
	rotate_timer += delta
	
	if rotate_timer > TIME_TO_ROTATE:
		rotate_timer = fmod(rotate_timer, TIME_TO_ROTATE)
		direction = (direction + randi() % 2 * 2 + 1) % 4
		frame = BASE_FRAME + direction
	else:
		for i in [0, 2]:
			var d = (direction + i) % 4
			var next = map_pos + global.dir2vec(d)
			if can_move(next):
				move(next)
				if i == 2:
					rotate_timer += TIME_TO_ROTATE / 2
				break