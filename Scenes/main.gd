extends Node2D

const SPAWN_TIMEOUT = 3
const WIDTH = 32
const HEIGHT = 18

var points = {}
var walls = {}
var timer = 0

func _ready():
	randomize()
	
	var M = preload("res://Scripts/maptools.gd")
	var m = preload("res://Scripts/intMap.gd").new(Vector2(WIDTH, HEIGHT), 0)
	
	var plus_mask = M.create_map_from_string(".#.\n#@#\n.#.", 1)
	var line3 = M.create_map_from_string("##@##\n", 1)
	m.bit_noise(0.6)
	m.and_mask(plus_mask)
	m.or_mask(plus_mask)
	m.sub2i(1)
	m.set_bounds()
	m.and_mask(plus_mask)
	m.and_mask(plus_mask)
	m.or_mask(plus_mask)
	m.set_bounds()
	
	for x in range(WIDTH):
		for y in range(HEIGHT):
			var p = Vector2(x, y)
			if m.get(p):
				walls[p] = true
				$walls.set_cell(x,y,0)
	
	
	m.sub2i(1)
	m.and_mask(line3, true)
	var possible_starts = []
	for x in range(WIDTH):
		for y in range(HEIGHT):
			var p = Vector2(x, y)
			if m.get(p):
				possible_starts.push_back(p)
	var indx = randi() % len(possible_starts)
	
	var s = preload("snake.tscn").instance()
	s.global_position = map2global(possible_starts[indx])
	add_child(s)
	
	global.map = self
	global.camera = $camera
	if has_node("snake"):
		$snake.connect("dead", self, "_on_player_dead")
		$snake.update_camera()
	else:
		$camera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	update_border_polygon()
	get_tree().connect("screen_resized", self, "update_border_polygon")

func update_border_polygon(data=null):
	$borders.invert_border = get_viewport_rect().size.x / 2
	for i in range(4):
		var p = $borders.polygon[i]
		$borders.polygon[i] = Vector2(WIDTH*sign(p.x), HEIGHT*sign(p.y)) * global.CELL_SIZE

func _on_player_dead():
	$snake.cut_tail()
	var t = $snake.TailPart.instance()
	t.frame = $snake/head.frame
	t.global_position = $snake/head.global_position
	t.to_destroy()
	add_tail_wall(t)
	t.connect('destroy', get_tree(), "reload_current_scene")

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
		if points.get(p) == null and not walls.get(p):
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

func add_tail_wall(t):
	add_child(t)
	var p = global2map(t.global_position)
	walls[p] = true
	t.connect("destroy", self, 'remove_wall', [p], CONNECT_ONESHOT)

func remove_wall(p):
	p = p.floor()
	walls.erase(p)

func has_wall(p):
	p = p.floor()
	return walls.get(p)

func map2global(v : Vector2) -> Vector2:
	return (v + Vector2.ONE/2) * global.CELL_SIZE

func global2map(v: Vector2) -> Vector2:
	return (v / global.CELL_SIZE).floor()