extends Node2D

const STEP_TIME = 0.5
const CELL_SIZE = 4
const GLOBAL_CELL_SIZE = CELL_SIZE*8

var linear_vel = Vector2(1,0)
var direction = 0
var map_pos
var timer = 0
var input_dir = 0
var tail_len = 2
var tail_nodes = []

var TailPart = preload("res://Scenes/snake_tail.tscn")

onready var head = $head

func _ready():
	map_pos = (global_position / GLOBAL_CELL_SIZE).floor()
	global_position = Vector2()
	head.global_position = map2global(map_pos)
	for i in range(2):
		var t = TailPart.instance()
		t.frame = 2 - i*2
		add_child(t)
		t.global_position = map2global(map_pos - (i+1)*Vector2(1,0))
		tail_nodes.push_back(t)

func _process(delta):
	timer += delta
	if timer > STEP_TIME:
		timer -= STEP_TIME
		
		var t = tail_nodes.pop_back()
		t.frame = 2 + input_dir
		t.rotation = direction * PI / 2
		t.global_position = map2global(map_pos)
		tail_nodes.push_front(t)
		
		direction = (direction + input_dir + 4) % 4
		linear_vel = Vector2(1 - direction % 2, direction % 2) * (1 - int(direction / 2) % 2 * 2)
		
		map_pos += linear_vel 
		head.global_position = map2global(map_pos)
		head.rotation = direction * PI/2
		
		tail_nodes[tail_len-1].frame = 0
		if tail_len > 1:
			tail_nodes[tail_len-1].rotation = tail_nodes[tail_len-2].rotation
		else:
			tail_nodes[tail_len-1].rotation = head.rotation
		
		input_dir = 0
		
	
	if Input.is_action_just_pressed("turn_left"):
		input_dir = -1
	if Input.is_action_just_pressed("turn_right"):
		input_dir = 1

func map2global(v : Vector2) -> Vector2:
	return (v + Vector2.ONE/2) * GLOBAL_CELL_SIZE