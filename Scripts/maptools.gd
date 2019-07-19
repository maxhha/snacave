const Map = preload('res://Scripts/intMap.gd')

static func create_distrev_map(center, size, objects_coords, w):
	var map = Map.new(size)
	map.start = center.floor();
	for x in range(-map.start.x, -map.start.x + map.size.x):
		for y in range(-map.start.y, -map.start.y + map.size.y):
			var sum = 0
			var c = Vector2(x,y)
			for p in objects_coords:
				sum += max(w - c.distance_to(p), 0)
			map.set(c, round(sum))
	return map

static func create_map_from_string(s, center_val = 0, row_seperator ='\n'):
	var rows = s.split(row_seperator)
	for i in range(len(rows)-1, -1, -1):
		if len(rows[i]) == 0:
			rows.remove(i)
	var size = Vector2(0, len(rows))
	for i in rows:
		size.x = max(size.x, len(i))
	
	var map = Map.new(size)
	var player_pos = null
	for y in range(size.y):
		for x in range(size.x):
			var p = Vector2(x, y)
			if rows[y][x] == '#':
				map.set(p, 1)
			elif rows[y][x] == '@':
				player_pos = p
				map.set(p, center_val)
			else:
				map.set(p, 0)
	assert(player_pos != null)#no @
	map.start = player_pos
	return map

static func map_compress_by_max(map, new_size):
	
	var new_map = Map.new(new_size)
	
	var kx = map.size.x / new_size.x
	var ky = map.size.y / new_size.y
	for x in range(new_size.x):
		for y in range(new_size.y):
			var w = range(floor(x*kx), ceil((x+1)*kx))
			var h = range(floor(y*ky), ceil((y+1)*ky))
			var m = map.data[x*kx+y*ky*map.size.x]
			for x1 in w:
				for y1 in h:
					m = max(m, map.data[x1 + map.size.x * y1])
			new_map.data[x + new_size.x * y] = m
	
	new_map.start.x = map.size.x / kx
	new_map.start.y = map.size.y / ky

static func check_line(map, p1, p2, val, def_val):
	var dir = p2 - p1
	var step = dir / max(abs(dir.x), abs(dir.y))
	
	var curr = p1
	var curr_s = p1 + step
	var new_curr = Vector2(round(curr_s.x), round(curr_s.y))
	while true:
		
		if map.get(curr, def_val) == val:
			return true
		var d = new_curr - curr
		
		if curr == p2:
			break
		
		if (d).length() > 1 and (map.get(curr + Vector2(d.x, 0), def_val) == val and map.get(curr + Vector2(0, d.y), def_val) == val):
			return true
		
		curr = new_curr
		
		curr_s += step
		new_curr = Vector2(round(curr_s.x), round(curr_s.y))
		
	return false


