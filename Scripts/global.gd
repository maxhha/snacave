extends Node

const CELL_SIZE = 4*8

# warning-ignore:unused_class_variable
var map
# warning-ignore:unused_class_variable
var camera
# warning-ignore:unused_class_variable
var snake
# warning-ignore:unused_class_variable
var max_score = 0
var new_max_score = false
var sess_max_score = 0

var first_game = true


const SAVE_FILE = 'user://data.json'

func _ready():
	var f = File.new()
	var data = {}
	if f.file_exists(SAVE_FILE):
		f.open(SAVE_FILE, File.READ)
		var json_result = JSON.parse(f.get_as_text())
		if json_result.error == OK and typeof(json_result.result) == TYPE_DICTIONARY:
			data = json_result.result
		f.close()
	
	max_score = data.get('score', 0)

func update_score(s):
	sess_max_score = max(sess_max_score, s)
	if s > max_score:
		new_max_score = true
		max_score = s
		var data = {'score':max_score}
		var f = File.new()
		f.open(SAVE_FILE, File.WRITE)
		f.store_string(JSON.print(data))
		f.close()


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