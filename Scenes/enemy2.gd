extends "Enemy.gd"

var side = null

# warning-ignore:unused_argument
func logic(delta):
	var set_side = true
	for i in [0, 1, 3]:
		var d = (direction + i) % 4
		var next = map_pos + global.dir2vec(d)
		var is_free = can_move(next)
		if is_free == (i == 0):
			set_side = false
			break
	
	if side == null or set_side:
		var d = (direction) % 4
		var next = map_pos + global.dir2vec(d)
		if can_move(next):
			move(next)
			return
		else:
			side = 1 + randi()%2 * 2
			direction = (direction + 4 - side) % 4
	
	for i in [side, 0, 4 - side, 2]:
		var d = (direction + i) % 4
		var next = map_pos + global.dir2vec(d)
		if can_move(next):
			move(next)
			break