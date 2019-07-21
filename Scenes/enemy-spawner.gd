extends Sprite
#
#const SPAWN_TIMEOUT = 10
#var map_pos
#var timer = randf()
## Called when the node enters the scene tree for the first time.
#func _ready():
#	map_pos = global.global2map(global_position)
#
#func _process(delta):
#	timer += delta
#	if is_instance_valid(global.snake) and global.snake.is_at(map_pos):
#		return queue_free()
#
#	if timer > SPAWN_TIMEOUT:
#		timer = fmod(timer , SPAWN_TIMEOUT)
#		if global.map.get_enemy(map_pos) or (is_instance_valid(global.snake) and global.snake.is_at(map_pos)):
#			timer += 0.5
#			return
#
#		var e = global.map.EnemyClasses[randi() % 4].instance()
#		e.global_position = global_position
#		global.map.add_enemy(e)