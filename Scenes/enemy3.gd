extends Sprite

var TIME_TO_ROTATE = 5 + randf() * 10

const STEP_TIME = 0.2
const BASE_FRAME = 76
var direction = randi() % 4
var last_map_pos
var map_pos
var timer = randf()
var rotate_timer = randf()

signal dead;

func _ready():
	map_pos = (global_position / global.CELL_SIZE).floor()
	global_position = map2global(map_pos)

func _process(delta):
	timer += delta
	if timer > STEP_TIME and not is_queued_for_deletion():
		rotate_timer += timer
		timer = fmod(timer, STEP_TIME)
		
		if rotate_timer > TIME_TO_ROTATE:
			rotate_timer = fmod(rotate_timer, TIME_TO_ROTATE)
			direction = (direction + randi() % 2 * 2 + 1) % 4
			frame = BASE_FRAME + direction
		else:
			var moved = false
			for i in [0, 2]:
				var d = (direction + i) % 4
				var next = map_pos + global.dir2vec(d)
				if not (global.map.has_wall(next) or global.map.get_enemy(next)):
					map_pos = next
					direction = d
					frame = BASE_FRAME + direction
					if is_instance_valid(global.snake):
						if global.snake.is_at(map_pos):
							if global.snake.can_hit(map_pos, map_pos - global.dir2vec(d)):
								global.snake.hit(map_pos)
							map_pos -= global.dir2vec(d)
					if i == 2:
						rotate_timer += TIME_TO_ROTATE / 4
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