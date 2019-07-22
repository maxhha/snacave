extends Node2D

const UPDATE_REACHABLE_PLACES_TIMEOUT = 20

const MAX_ENEMIES = 40
const MAX_APPLES = 1
const POWERUP_N = 6
const POWERUP_PROB = 0.2
#const COUNT_SPAWNERS = 0

var apple_number = POWERUP_N - 4

const WIDTH = 80
const HEIGHT = 80

var apples = {}
var walls = {}
var enemies = {}
var timer = 0
var spawners = []

var reachables = {}

const EnemyClasses = [
	preload("res://Scenes/enemy1.tscn"),
	preload("res://Scenes/enemy2.tscn"),
	preload("res://Scenes/enemy3.tscn"),
	preload("res://Scenes/enemy4.tscn")
]

const EnemyClassesProb = [6,6,1,1]
const EnemyClassesProbSum = 6+6+1+1

func _ready():
	global.sess_max_score = 0
	global.new_max_score = false
	randomize()
	
	var M = preload("res://Scripts/maptools.gd")
	var m = preload("res://Scripts/intMap.gd").new(Vector2(WIDTH, HEIGHT), 0)
	
	var plus3_mask = M.create_map_from_string(".#.\n#@#\n.#.", 1)
	var plus5_mask = M.create_map_from_string("..#..\n..#..\n##@##\n..#..\n..#..", 1)
	var line3 = M.create_map_from_string("##@##\n", 1)
	m.bit_noise(0.45)
	m.and_mask(plus3_mask)
	m.or_mask(plus5_mask)
	m.sub2i(1)
	m.set_bounds()
	m.and_mask(plus3_mask)
	m.or_mask(plus3_mask)
#	m.or_mask(plus5_mask)
	m.set_bounds()
	
	for x in range(WIDTH):
		for y in range(HEIGHT):
			var p = Vector2(x, y)
			if m.get(p):
				walls[p] = true
				$walls.set_cell(x,y,0)
	
	m.sub2i(1)
	var m2 = m.clone()
	
	m.and_mask(line3, true)
	var possible_starts = []
	for x in range(WIDTH):
		for y in range(HEIGHT):
			var p = Vector2(x, y)
			if m.get(p):
				possible_starts.push_back(p)
	var indx = randi() % len(possible_starts)
	
	if not global.first_game:
		var s = preload("snake.tscn").instance()
		s.global_position = map2global(possible_starts[indx])
		add_child(s)
	
		global.snake = s
		update_reachable_places(false)
	
		for x in range(-7, 8):
			for y in range(-7, 8):
				m2.set(possible_starts[indx] + Vector2(x,y), 0)
	
	var last_enemy
	
	for i in range(max(int(global.first_game), MAX_ENEMIES)):
		var s = i % EnemyClassesProbSum
		i = 0
		while s > 0:
			s -= EnemyClassesProb[i]
			i += 1
		
		var e = EnemyClasses[i].instance()
		var p 
		while true:
			p = Vector2(randi() % WIDTH, randi() % HEIGHT)
			if m2.get(p):
				m2.set(p, 0)
				break
		e.global_position = map2global(p)
		add_enemy(e)
		last_enemy = e
	
# warning-ignore:unused_variable
#	for i in range(COUNT_SPAWNERS):
#		var e = preload("res://Scenes/enemy-spawner.tscn").instance()
#		var p 
#		while true:
#			p = Vector2(randi() % WIDTH, randi() % HEIGHT)
#			if m2.get(p):
#				m2.set(p, 0)
#				break
#		e.global_position = map2global(p)
#		add_child(e)
#		spawners.push_back(e)
	
	if not global.first_game:
# warning-ignore:unused_variable
		for i in range(MAX_APPLES):
			random_place_apple(Apple.instance())
	
	
	global.map = self
	global.camera = $camera
	if has_node("snake"):
# warning-ignore:return_value_discarded
		$snake.connect("dead", self, "_on_player_dead")
		$snake.update_camera()
		global.snake = $snake
	else:
		var cam = $camera
		remove_child(cam)
		last_enemy.add_child(cam)
	
	update_border_polygon()
# warning-ignore:return_value_discarded
	get_tree().connect("screen_resized", self, "update_border_polygon")
	if global.first_game:
		$UI/anim.play('mainmenu_fadein')
	
	global.first_game = false

func spawn_enemy(i):
	var e = EnemyClasses[i].instance()
	var s = get_viewport_rect().size / global.CELL_SIZE
	s = max(s.x, s.y)
	var p
	while true:
		p = Vector2(randi() % WIDTH, randi() % HEIGHT)
		
		if (enemies.get(p) == null 
			and not has_wall(p)
			and not (is_instance_valid(global.snake) 
					and global.snake.is_at(p)
					and (p - global.snake.map_pos).length_squared() > s
			)):
			break
	e.global_position = map2global(p)
	add_enemy(e)

func add_enemy(e):
	add_child(e)
	e.connect('dead', self, '_on_enemy_dead', [e], CONNECT_ONESHOT)

# warning-ignore:unused_argument
func update_border_polygon(data=null):
	var wall_rect = $walls.get_used_rect()
	var top_left = -wall_rect.position * global.CELL_SIZE
	var bottom_right = (wall_rect.end - Vector2(WIDTH, HEIGHT)) * global.CELL_SIZE
	var viewport_size = get_viewport_rect().size
	$borders.invert_border = (max(viewport_size.x, viewport_size.y) / 2 + 
		max(max(top_left.x, top_left.y), max(bottom_right.x, bottom_right.y))
		)
	for i in range(4):
		var p = $borders.polygon[i]
		$borders.polygon[i] = Vector2(WIDTH*sign(p.x), HEIGHT*sign(p.y)) * global.CELL_SIZE

func _on_player_dead():
	global.snake = null
	$snake.cut_tail()
	var t = $snake.TailPart.instance()
	t.frame = $snake/head.frame
	t.global_position = $snake/head.global_position
	t.to_destroy()
	add_tail_wall(t)
	$UI/gameover/vbox1/wow.visible = global.new_max_score
	$UI/gameover/vbox1/lbl_score.visible = not global.new_max_score
	$UI/gameover/vbox1/score.text = str(global.sess_max_score)
	$UI/gameover/vbox2/max_score.text = str(global.max_score)
	$UI/anim.play('gameover_fadein')

func _on_enemy_dead(e):
	enemies.erase(e.last_map_pos)
	var s : String = e.filename
	s = s.trim_prefix("res://Scenes/enemy").trim_suffix(".tscn")
	spawn_enemy(int(s)-1)

func _process(delta):
	timer += delta
	if timer > UPDATE_REACHABLE_PLACES_TIMEOUT:
		timer -= UPDATE_REACHABLE_PLACES_TIMEOUT
		update_reachable_places()

func update_reachable_places(should_yeild=true):
	if not is_instance_valid(global.snake):
		return
	var TIME = OS.get_ticks_usec()
	var open = [global.snake.map_pos]
	var map = {}
	
	while open.size() > 0:
		var p = open.pop_front()
		if p in map or has_wall(p):
			continue
			
		map[p] = true
		for i in range(4):
			open.append(p + global.dir2vec(i))
		
		if should_yeild:
			var t = OS.get_ticks_usec()
			if t - TIME > 2000:
				TIME = t
				yield(get_tree(), "idle_frame")
	
	reachables = map
	

var Apple = preload("res://Scenes/apple.tscn")
var PowerupApple = preload("res://Scenes/powerup_apple.tscn")

func random_place_apple(a):
	if not a.is_inside_tree():
		add_child(a)
	var p
	while true:
		p = Vector2(randi() % WIDTH, randi() % HEIGHT)
		
		if (apples.get(p) == null 
			and p in reachables
			and not (is_instance_valid(global.snake) 
					and global.snake.is_at(p)
			)):
			var s = 0
			for i in range(4):
				s += int(reachables.get(p + global.dir2vec(i), false))
			if s > 1:
				break
	a.global_position = map2global(p)
	apples[p] = a

#func spawn():
#	var a
#	if randf() > 0.2:
#		a = Apple.instance()
#	else:
#		a = PowerupApple.instance()
#	var p
#	while true:
#		p = Vector2(randi() % WIDTH, randi() % HEIGHT)
#		if apples.get(p) == null and not walls.get(p):
#			break
#	add_child(a)
#	a.global_position = map2global(p)
#	apples[p] = a

func get_apple(p):
	p = p.floor()
	return apples.get(p)

func remove_apple(p):
	if not apples[p].is_in_group('oneshot'):
		apple_number += 1
		if apple_number % POWERUP_N > 0:
			random_place_apple(Apple.instance())
		else:
			random_place_apple(PowerupApple.instance())
	
	apples[p].queue_free()
	apples.erase(p)

func place_apple(p):
	var a = PowerupApple.instance()
	a.add_to_group("oneshot")
	add_child(a)
	a.global_position = map2global(p)
	apples[p] = a

func add_tail_wall(t):
	add_child(t)
	var p = global2map(t.global_position)
	walls[p] = true
	t.connect("destroy", self, 'remove_wall', [p], CONNECT_ONESHOT)

func remove_wall(p):
	p = p.floor()
	walls.erase(p)
	if $walls.get_cellv(p) == 0:
		$walls.set_cellv(p, -1)
	elif not inside_map(p):
		walls[p] = false
		$walls.set_cellv(p, 1)
		update_border_polygon()

func has_wall(p):
	p = p.floor()
	if p in walls:
		return walls[p]
	else:
		return not inside_map(p)

func inside_map(p):
	return p.x >= 0 and p.y >= 0 and p.x < WIDTH and p.y < HEIGHT

func get_enemy(p):
	p = p.floor()
	var e = enemies.get(p)
	assert(not is_instance_valid(e) or "enemy" in e.filename)
#	if (e and not is_instance_valid(e)) or (is_instance_valid(e) or not "enemy" in e.filename):
#		enemies.erase(p)
#		print('~~~~~~~~~~~~~~~~~~~hotfix', p)
	return e

func move_enemy(e):
	if e.last_map_pos:
		enemies[e.last_map_pos] = null
	e.last_map_pos = e.map_pos
	enemies[e.map_pos] = e

func map2global(v : Vector2) -> Vector2:
	return (v + Vector2.ONE/2) * global.CELL_SIZE

func global2map(v: Vector2) -> Vector2:
	return (v / global.CELL_SIZE).floor()

func _on_play_pressed():
# warning-ignore:return_value_discarded
	get_tree().create_timer(0.1).connect("timeout", get_tree(), "reload_current_scene")
