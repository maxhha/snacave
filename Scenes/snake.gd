extends Node2D

const STEP_TIMES = [0.5, 0.15]
const SPEEDUP_TIMEOUT = 1
const POWERUP_TIMEOUT = 10
const POWERUP_MAX_SPEED = 0.03
const POWERUP_MIN_SPEED = 0.5
var BASE_FRAME = 0
var speed = 0

var linear_vel = Vector2(1,0)
var direction = 0
var map_pos
var timer = 0
var speedup_timer = 0
var powerup_timer = 0
var input_dir = 0
var tail_nodes = []
var tail_points = {}
var apple_points = 0




var TailPart = preload("res://Scenes/snake_tail.tscn")

onready var head = $head

signal dead;

func _ready():
	
	map_pos = (global_position / global.CELL_SIZE).floor()
	global_position = Vector2()
	head.global_position = map2global(map_pos)
	var count = 2
	for i in range(count):
		var t = TailPart.instance()
		if i < count - 1:
			t.frame = 4
		else:
			t.frame = head.hframes

		add_child(t)
		t.global_position = map2global(map_pos - (i+1)*Vector2(1,0))
		tail_nodes.push_back(t)
		tail_points[map_pos - (i+1)*Vector2(1,0)] = t

enum {NORMAL, POWERUP}
var state = NORMAL

func _process(delta):
	timer += delta

	if state == POWERUP and powerup_timer == 0:
		finish_powerup()
	powerup_timer = max(0, powerup_timer - delta)

#	if speed & 1 and tail_nodes.size() < 2:
#		speed = speed & 2
#	speedup_timer += int(speed == 1) * delta
	
#	if speedup_timer >= SPEEDUP_TIMEOUT:
#		speedup_timer = fmod(speedup_timer, SPEEDUP_TIMEOUT)
#		var t = tail_nodes.pop_back()
#		tail_points.erase(global2map(t.global_position))
#		t.queue_free()
	var time = get_step_time()
	if timer >= time and is_instance_valid(self):
		var d = timer
		timer = fmod(timer , time)
		logic(delta)
	
	if Input.is_action_just_pressed("turn_left"):
		input_dir = -1
	if Input.is_action_just_pressed("turn_right"):
		input_dir = 1
	if Input.is_action_just_pressed("speedup"):
		if (speed & 1) or true:#tail_nodes.size() > 1:
			speed = (speed & 2) + (1 - (speed & 1))

func get_step_time():
	if state == NORMAL:
		return STEP_TIMES[speed]
	else:
		return lerp(POWERUP_MIN_SPEED, POWERUP_MAX_SPEED, min(1, powerup_timer/POWERUP_TIMEOUT))

func logic(delta):
	
	var next_direction = (direction + input_dir + 4) % 4
	var next = map_pos + global.dir2vec(next_direction)
	
	# collision with walls
	if global.map.has_wall(next):
		if state == NORMAL:
			kill()
			return
		else:
			global.map.remove_wall(next)
	
	#collsision with tail
	if next in tail_points:
		var indx = tail_nodes.find(tail_points[next])
		cut_tail(indx+1)
	
	# move sigment 
	var t
	
	if apple_points > 0:
		apple_points -= 1
		
		t = TailPart.instance()
		add_child(t)
	else:
		t =  tail_nodes.pop_back()
		tail_points.erase(global2map(t.global_position))
	
	if input_dir == 0:
		t.frame = 4 + direction + BASE_FRAME
	elif input_dir > 0:
		t.frame = direction + BASE_FRAME
	else:
		t.frame = (direction + 1) % 4 + BASE_FRAME
	
	t.global_position = map2global(map_pos)

	tail_nodes.push_front(t)
	tail_points[map_pos] = t
	
	var e = global.map.get_enemy(next)
	if e:
		e.kill()
		apple_points += 1
#		if state == NORMAL and false:
#			kill()
#			return
#		else:
#			e.kill()
#			apple_points += 1
	
	# update apple points
	var a = global.map.get_apple(next)
	if a:
		if a.is_in_group('powerup'):
			powerup_timer = POWERUP_TIMEOUT
			if state == NORMAL:
				start_powerup()
		else:
			apple_points += 1
		global.map.remove_apple(next)
	
	# update head
	head.global_position = map2global(next)
	head.frame = 8 + next_direction + head.hframes * int(speed > 0) + BASE_FRAME
	
	# update tail
	var last = tail_nodes[len(tail_nodes) - 1]
	var prelast = tail_nodes[len(tail_nodes) - 2] if len(tail_nodes) >= 2 else head
	
	var d = prelast.global_position - last.global_position
	var dir = global.vec2dir(d)
	last.frame = head.hframes + dir + BASE_FRAME
	
	direction = next_direction
	map_pos = next
	input_dir = 0
	update_camera()
	$UI/Control/score.text = str(len(tail_nodes))
	global.update_score(len(tail_nodes))

func start_powerup():
	state = POWERUP
	BASE_FRAME = head.hframes * 2
	speed |= 2
	update_all_skins()

func finish_powerup():
	state = NORMAL
	BASE_FRAME = 0
	speed = 0
	update_all_skins()

func update_all_skins():
	for t in tail_nodes:
		t.frame = t.frame % (head.hframes * 2) + BASE_FRAME
	head.frame = head.frame % (head.hframes * 2) + BASE_FRAME

func update_camera():
	if is_instance_valid(global.camera):
		global.camera.global_position = $head.global_position

func cut_tail(indx = 0):
	for i in range(len(tail_nodes)-1, indx-1, -1):
		var t = tail_nodes[i]
		remove_child(t)
		global.map.add_tail_wall(t)
		tail_points.erase(global2map(t.global_position))
		t.to_destroy()
		tail_nodes.remove(i)

func is_at(p:Vector2) -> bool:
	return p == map_pos or p in tail_points
 
func can_hit(p: Vector2, s: Vector2) -> bool:
	return state == NORMAL and ((p == map_pos and s - p != global.dir2vec(direction)) or p in tail_points)

func hit(pos):
	if pos == map_pos:
		kill()
		return
	var indx = tail_nodes.find(tail_points[pos])
	if indx == 0:
		kill()
	else:
		cut_tail(indx)

func kill():
	emit_signal("dead")
	queue_free()

func map2global(v : Vector2) -> Vector2:
	return (v + Vector2.ONE/2) * global.CELL_SIZE

func global2map(v: Vector2) -> Vector2:
	return (v / global.CELL_SIZE).floor()