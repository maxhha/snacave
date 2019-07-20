extends Node

const CELL_SIZE = 4*8

# warning-ignore:unused_class_variable
var map
# warning-ignore:unused_class_variable
var camera
# warning-ignore:unused_class_variable
var snake

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

const DIR2VEC = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]

func dir2vec(d:int)->Vector2:
	return DIR2VEC[d]

func vec2dir(vec: Vector2) -> int:
	if abs(vec.x) > abs(vec.y):
		vec.x = sign(vec.x)
		vec.y = 0
	else:
		vec.y = sign(vec.y)
		vec.x = 0
	return DIR2VEC.find(vec)

func map2global(v : Vector2) -> Vector2:
	return (v + Vector2.ONE/2) * CELL_SIZE

func global2map(v: Vector2) -> Vector2:
	return (v / CELL_SIZE).floor()