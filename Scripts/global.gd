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
