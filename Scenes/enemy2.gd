extends Sprite

const STEP_TIME = 0.5
var direction = randi() % 4

var last_map_pos
var map_pos
var timer = randf()

var side = null

var wall

signal dead;

func _ready():
	map_pos = (global_position / global.CELL_SIZE).floor()
	global_position = map2global(map_pos)

func _process(delta):
	timer += delta
	if timer > STEP_TIME and not is_queued_for_deletion():
		timer = fmod(timer, STEP_TIME)
		
		var set_side = true
		for i in [0, 1, 3]:
			var d = (direction + i) % 4
			var next = map_pos + global.dir2vec(d)
			var is_wall = global.map.has_wall(next) or global.map.get_enemy(next)
			if is_wall != (i == 0):
				set_side = false
				break
		
		if side == null or set_side:
			var d = (direction) % 4
			var next = map_pos + global.dir2vec(d)
			if not (global.map.has_wall(next) or global.map.get_enemy(next)):
				map_pos = next
				direction = d
				frame = 60 + direction
				if is_instance_valid(global.snake):
					if global.snake.is_at(map_pos):
						if global.snake.can_hit(map_pos, map_pos - global.dir2vec(d)):
							global.snake.hit(map_pos)
						map_pos -= global.dir2vec(d)
						
				global_position = map2global(map_pos)
				global.map.move_enemy(self)
				return
			else:
				side = 1 + randi()%2 * 2
				direction = (direction + 4 - side) % 4
		
		for i in [side, 0, 4 - side, 2]:
			var d = (direction + i) % 4
			var next = map_pos + global.dir2vec(d)
			if not (global.map.has_wall(next) or global.map.get_enemy(next)):
				map_pos = next
				direction = d
				frame = 60 + direction
				if is_instance_valid(global.snake):
					if global.snake.is_at(map_pos):
						if global.snake.can_hit(map_pos, map_pos - global.dir2vec(d)):
							global.snake.hit(map_pos)
						map_pos -= global.dir2vec(d)
						
				global_position = map2global(map_pos)
				global.map.move_enemy(self)
				break
			

func kill():
	emit_signal("dead")
	queue_free()

func map2global(v : Vector2) -> Vector2:
	return (v + Vector2.ONE/2) * global.CELL_SIZE

func global2map(v: Vector2) -> Vector2:
	return (v / global.CELL_SIZE).floor()