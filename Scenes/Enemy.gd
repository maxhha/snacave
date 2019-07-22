extends Sprite

export (float) var STEP_TIME = 0.5
export (int) var BASE_FRAME = 44
var direction = randi() % 4
var last_map_pos
var map_pos
var step_timer = randf()

signal dead;

func _ready():
	map_pos = (global_position / global.CELL_SIZE).floor()
	global_position = global.map2global(map_pos)

func _process(delta):
	step_timer += delta
	if step_timer > STEP_TIME and not is_queued_for_deletion():
		var d = step_timer
		step_timer = fmod(step_timer, STEP_TIME)
		
#		if is_instance_valid(global.snake):
#			var s = 0
#			for i in range(4):
#				var p = map_pos + global.dir2vec(i)
#				s += int(can_move(p))
#			if s == 0:
#				kill()
#				global.map.place_apple(map_pos)
#				return
		logic(d)

func update_sprite():
	frame = BASE_FRAME + direction
	global_position = global.map2global(map_pos)

func can_move(next):
	return not (global.map.has_wall(next) or global.map.get_enemy(next) or (is_instance_valid(global.snake) and global.snake.is_at(next)))

func move(next):
	var prev = map_pos
	direction = global.vec2dir(next - map_pos)
	map_pos = next
	if is_instance_valid(global.snake):
		if global.snake.is_at(map_pos):
			if global.snake.can_hit(map_pos, prev):
				global.snake.hit(map_pos)
			map_pos = prev
			
	global.map.move_enemy(self)
	update_sprite()
	
func logic(delta):
	pass

func kill():
	emit_signal("dead")
	queue_free()