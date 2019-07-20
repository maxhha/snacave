extends "Enemy.gd"

# warning-ignore:unused_argument
func logic(delta):
	var r = randi() % 2
	for i in [0, 1 + r*2, 3 - r*2, 2]:
		var d = (direction + i) % 4
		var next = map_pos + global.dir2vec(d)
		if can_move(next):
			move(next)
			break