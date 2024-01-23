extends Node2D

var laser_scene: PackedScene = preload("res://Scenes/Player/laser.tscn")
var explode_block_scene: PackedScene = preload("res://Scenes/Blocks/explodey_block.tscn")

var item_scenes: Array[PackedScene] = [preload("res://Scenes/Items/laser_item.tscn"),
										preload("res://Scenes/Items/magnet_item.tscn"),
										preload("res://Scenes/Items/boom_item.tscn"),
										preload("res://Scenes/Items/slow_slow_item.tscn"),
										preload("res://Scenes/Items/explode_mult_item.tscn")]

var ball_collision_level = 2
var tilemap_layer = 0

var start_of_game: bool = true
var offset
@export var is_player_magnet: bool = false
var is_ball_magnetized: bool = true

@export var ball_start_speed = 250
@export var ball_speed = 250
@export var ball_speed_up = 10
@export var ball_max_speed = 500

@export var item_drop_precent = 2

func _ready():
	calc_ball_offset()

func _process(_delta):
	if (start_of_game or is_ball_magnetized):
		$Ball.linear_velocity = Vector2.ZERO
		$Ball.global_position.x = ($Player.global_position.x + offset)

func _on_player_laser_fired(laser_positions: Array[Node]):
	var laser_left = laser_scene.instantiate()
	var laser_right = laser_scene.instantiate()
	laser_left.position = laser_positions[0].global_position
	laser_right.position = laser_positions[1].global_position
	$Projectiles.add_child(laser_left)
	$Projectiles.add_child(laser_right)

func _unhandled_input(event):
	if event is InputEventScreenTouch:
		if event.is_released() and (start_of_game or (is_player_magnet and is_ball_magnetized)):
			var ball_direction = ($Ball.global_position - $Player.global_position).normalized()
			$Ball.linear_velocity = ball_direction * ball_speed
			start_of_game = false
			is_ball_magnetized = false

func _on_ball_touch_player(ball_direction):
	if (is_player_magnet && $Ball.position.y < $Player.position.y - 5):
		is_ball_magnetized = true
		calc_ball_offset()
	update_ball_velocity(ball_direction)

func update_ball_velocity(ball_direction: Vector2):
	$Ball.linear_velocity = ball_direction * ball_speed

func calc_ball_offset():
	offset = $Ball.global_position.x - $Player.global_position.x

func _on_game_over_zone_body_entered(body):
	if (body.collision_layer == ball_collision_level):
		$Ball.global_position = $Player.global_position + Vector2(5, -25)
		calc_ball_offset()
		start_of_game = true
	else:
		body.queue_free()

func _on_ball_speed_up():
	if ball_speed < ball_max_speed:
		ball_speed += ball_speed_up
	else:
		ball_speed = ball_max_speed

#Spawn Item

func _on_block_tilemap_child_exiting_tree(node):
	if(!node.is_in_group("explodey_pickup") and randi() % 100 < item_drop_precent):
		var item: BaseItem = pick_item()
		item.position = node.position
		$Items.add_child(item)

func pick_item() -> BaseItem:
	var random = randi() % 100
	var n = 100 / item_scenes.size()
	
	for i in range(item_scenes.size()):
		if(random < (i+1) * n):
			return item_scenes[i].instantiate()
	return item_scenes.back().instantiate()

#Item Pickups

func _on_player_activate_magnet():
	is_player_magnet = true

func _on_player_activate_boom():
	var blocks = $BlockTilemap.get_children()
	for block in blocks:
		if "explode" in block:
			block.explode()


func _on_player_activate_slow_slow():
	ball_speed = ball_start_speed
	update_ball_velocity($Ball.linear_velocity.normalized())


func _on_player_activate_explode_mult():
	var tilemap: TileMap = $BlockTilemap
	var neighbors: Array = []
	
	neighbors.assign(get_neighbor_positions_of_explodeys())
	for block in neighbors:
		block.add_to_group("explodey_pickup")
		tilemap.set_cell(tilemap_layer, tilemap.local_to_map(block.position), 0, Vector2i(0, 0), 1)
	
	var explodey_blocks: Array = get_explodey_blocks()
	for block in explodey_blocks:
		block.restart_animation()
	

func get_neighbor_positions_of_explodeys() -> Array:
	var explodey_blocks: Array = get_explodey_blocks()
	var neighbors: Array = []
	
	for explodey_block in explodey_blocks:
		neighbors.append_array(get_neighbor_positions_of_block(explodey_block.position))
	
	return neighbors
#
func get_explodey_blocks() -> Array:
	var explodey_blocks: Array = []
	
	explodey_blocks.assign($BlockTilemap.get_children()\
	.filter(func(block): return "explode" in block))
	
	return explodey_blocks

func get_neighbor_positions_of_block(block_position: Vector2) -> Array:
	var neighbors: Array = []
	
	for tile in $BlockTilemap.get_children():
		if(is_tile_neighbor(block_position, tile.position)):
			neighbors.append(tile)
	
	return neighbors

func is_tile_neighbor(base_position: Vector2, tile_position: Vector2):
	var x_offset = 35
	var y_offset = 15
	
	var possible_x: Array = [base_position.x - x_offset, base_position.x + x_offset]
	var possible_y: Array = [base_position.y - y_offset, base_position.y + y_offset]
	
	if ((possible_x.has(tile_position.x) and tile_position.y == base_position.y)
	or (possible_y.has(tile_position.y) and tile_position.x == base_position.x)):
		return true
	return false
