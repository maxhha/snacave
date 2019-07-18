extends Node2D

const SPAWN_TIMEOUT = 3
const WIDTH = 32
const HEIGHT = 18


var points = {}
var timer = 0

func _ready():
	randomize()
	global.map = self

func _process(delta):
	timer += delta
	if timer > SPAWN_TIMEOUT:
		spawn()
		timer -= SPAWN_TIMEOUT

var Apple = preload("res://Scenes/apple.tscn")

func spawn():
	var a = Apple.instance()
	var p
	while true:
		p = Vector2(randi() % WIDTH, randi() % HEIGHT)
		if points.get(p) == null:
			break
	add_child(a)
	a.global_position = map2global(p)
	points[p] = a	

func has_apple(p):
	p = p.floor()
	return p in points

func remove_apple(p):
	points[p].queue_free()
	points.erase(p)

func map2global(v : Vector2) -> Vector2:
	return (v + Vector2.ONE/2) * global.CELL_SIZE