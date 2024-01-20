extends BaseBlock

func hit():
	$AnimationPlayer.play("explode")

func explode():
	for block in get_neighbors():
		if ("hit" in block):
			block.hit()

func get_neighbors():
	var tilemap: Array[Node] = get_parent().get_children()
	tilemap.sort()
	var neighbors: Array[Node] = []
	
	for tile in tilemap:
		if(is_tile_neighbor(tile)):
			neighbors.append(tile)
	
	return neighbors

func is_tile_neighbor(tile: Node):
	var x_offset = 35
	var y_offset = 15
	
	var possible_x: Array = [position.x - x_offset, position.x, position.x + x_offset]
	var possible_y: Array = [position.y - y_offset, position.y, position.y + y_offset]
	
	if (possible_x.has(tile.position.x) and possible_y.has(tile.position.y) and tile != self):
		return true
	return false
