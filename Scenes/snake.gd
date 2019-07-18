extends Node2D

const STEP_TIME = 0.5

var linear_vel = Vector2(1,0)
var direction = 0
var map_pos
var timer = 0
var input_dir = 0
var tail_nodes = []
var apple_points = 0

var TailPart = preload("res://Scenes/snake_tail.tscn")

onready var head = $head

func _ready():
	map_pos = (global_position / global.CELL_SIZE).floor()
	global_position = Vector2()
	head.global_position = map2global(map_pos)
	for i in range(2):
		var t = TailPart.instance()
		t.frame = 8 - i*8 + i * head.hframes
		add_child(t)
		t.global_position = map2global(map_pos - (i+1)*Vector2(1,0))
		tail_nodes.push_back(t)

func _process(delta):
	timer += delta
	if timer > STEP_TIME:
		timer -= STEP_TIME
		
		var next_direction = (direction + input_dir + 4) % 4
		var next_linear_vel = Vector2(1 - next_direction % 2, next_direction % 2) * (1 - int(next_direction / 2) % 2 * 2)
		var next_pos = map_pos + next_linear_vel 
		
		var t
		
		if apple_points > 0:
			apple_points -= 1
			
			t = TailPart.instance()
			add_child(t)
		else:
			t =  tail_nodes.pop_back()
		
		if input_dir == 0:
			t.frame = 8 + direction
		elif input_dir > 0:
			t.frame = direction
		else:
			t.frame = (direction + 1) % 4
		 
		t.global_position = map2global(map_pos)
		tail_nodes.push_front(t)
		
		direction = next_direction
		linear_vel = next_linear_vel
		
		map_pos += linear_vel
		
		if global.map.has_apple(next_pos):
			global.map.remove_apple(next_pos)
			apple_points += 1
		
		head.global_position = map2global(map_pos)
		head.frame = 4 + direction
		
		
		var last = len(tail_nodes) - 1
		
		if last > 0:
			var d = tail_nodes[last - 1].global_position - tail_nodes[last].global_position
			if abs(d.x) > abs(d.y):
				d.x = sign(d.x)
				d.y = 0
			else:
				d.x = 0
				d.y = sign(d.y)
				
			tail_nodes[last].frame = abs(d.y) + max(0, - d.x - d.y) * 2 + head.hframes
			
		else:
			tail_nodes[last].frame = direction + head.hframes
		
		input_dir = 0
		
	
	if Input.is_action_just_pressed("turn_left"):
		input_dir = -1
	if Input.is_action_just_pressed("turn_right"):
		input_dir = 1

func map2global(v : Vector2) -> Vector2:
	return (v + Vector2.ONE/2) * global.CELL_SIZE

func global2map(v: Vector2) -> Vector2:
	return (v / global.CELL_SIZE).floor()