var data
var size setget set_size
var start = Vector2()

func _init(sizee, fill = null):
	size = sizee.floor()
	data = PoolIntArray(range(size.x * size.y))
	if typeof(fill) == TYPE_INT:
		for i in range(size.x * size.y):
			data[i] = fill

func set(pos, val):
	pos = (pos + start).floor()
	if pos.x >= 0 and pos.y >= 0 and pos.x < size.x and pos.y < size.y:
		data[pos.x + pos.y*size.x] = val

func get(pos, val=0):
	pos = (pos + start).floor()
	if pos.x >= 0 and pos.y >= 0 and pos.x < size.x and pos.y < size.y:
		return data[pos.x + pos.y*size.x]
	else:
		return val

func has_point(pos):
	pos = (pos + start).floor()
	return (pos.x >= 0) and (pos.y >= 0) and (pos.x < size.x) and (pos.y < size.y)

func set_size(new_size):
	
	var new_data = PoolIntArray(range(new_size.x * new_size.y))
	
	var kx = size.x / new_size.x
	var ky = size.y / new_size.y
	for x in range(new_size.x):
		for y in range(new_size.y):
			var sum = 0
			var w = range(floor(x*kx), ceil((x+1)*kx))
			var h = range(floor(y*ky), ceil((y+1)*ky))
			for x1 in w:
				for y1 in h:
					sum += data[x1 + size.x * y1]
			new_data[x + new_size.x * y] = round(sum / len(w) / len(h))
	
	data = new_data
	size = new_size
	start.x /= kx
	start.y /= ky

func copy():
	return get_script().new(size);

func copy_data(map):
	for i in range(map.size.x*map.size.y):
		data[i] = map.data[i]

func clone():
	var new_map = get_script().new(size);
	new_map.copy_data(self)
	new_map.start = start
	return new_map

func bit_noise(k):
	for i in range(size.x*size.y):
		data[i] = 0 if randf() > k else 1

func sub2i(k):
	for i in range(size.x*size.y):
		data[i] = k - data[i]
	
func set_bounds(val = 1):
	for x in range(size.x):
		data[x] = val
		data[x + (size.y - 1)*size.x] = val;
	
	for y in range(size.y):
		data[y*size.x] = val
		data[size.x-1 + y*size.x] = val
	
func or_mask(mask):
	var new_data = PoolIntArray(range(data.size()));
	
	for i in range(data.size()):
		new_data[i] = 0
	
	var p
	for xc in range(size.x):
		for yc in range(size.y):
			var i = xc + yc*size.x
			if data[i] <= 0:
				continue
			var X = range(max(xc - mask.start.x,0), min(xc - mask.start.x + mask.size.x, size.x))
			var Y = range(max(yc - mask.start.y,0), min(yc - mask.start.y + mask.size.y, size.y))
			for x in X:
				for y in Y:
					p = Vector2(x-xc,y-yc)
					if mask.get(p, 0) > 0:
						 new_data[x + y*size.x] = mask.get(p, 0)
	data = new_data

func and_mask(mask, strictly=false):
	var new_data = PoolIntArray(range(data.size()));
	
	for i in range(data.size()):
		new_data[i] = 0
	
	var del
	var p
	var c_v = mask.get(Vector2())
	for xc in range(size.x):
		for yc in range(size.y):
			var i = xc + yc*size.x
			var c = Vector2(xc,yc)
			del = false
			if data[i] != c_v:
				continue
			var X = range(max(xc - mask.start.x,0), min(xc - mask.start.x + mask.size.x, size.x))
			var Y = range(max(yc - mask.start.y,0), min(yc - mask.start.y + mask.size.y, size.y))
			for x in X:
				for y in Y:
					p = Vector2(x,y) - c
					if strictly:
						del = del or mask.get(p) != data[x + y*size.x]
					else:
						del = del or mask.get(p) > data[x + y*size.x]
			if not del:
				new_data[i] = 1
	data = new_data

func sub_map(map, limit=-INF):
	for i in range(size.x*size.y):
		data[i] = max(limit, data[i] - map.data[i])

func add_map(map, limit=INF):
	for i in range(size.x*size.y):
		data[i] = min(limit, data[i] + map.data[i])