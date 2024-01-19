extends Node2D

var laser_scene: PackedScene = preload("res://Scenes/Player/laser.tscn")
var laser_item_scene: PackedScene = preload("res://Scenes/Items/laser_item.tscn")
var magnet_item_scene: PackedScene = preload("res://Scenes/Items/magnet_item.tscn")

var item_scenes: Array[PackedScene] = [preload("res://Scenes/Items/laser_item.tscn"),
										preload("res://Scenes/Items/magnet_item.tscn")]

var ball_collision_level = 2

var start_of_game: bool = true
var offset
var is_player_magnet: bool = false
var is_ball_magnetized: bool = true

@export var ball_speed = 200
@export var ball_speed_up = 5
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
	if (is_player_magnet):
		is_ball_magnetized = true
		calc_ball_offset()
	$Ball.linear_velocity = ball_direction * ball_speed

func calc_ball_offset():
	offset = $Ball.global_position.x - $Player.global_position.x

func _on_player_activate_magnet():
	is_player_magnet = true


func _on_game_over_zone_body_entered(body):
	if (body.collision_layer == ball_collision_level):
		$Ball.global_position = $Player.global_position + Vector2(3, -20)
		calc_ball_offset()
		start_of_game = true
	else:
		body.queue_free()


func _on_brick_tilemap_child_exiting_tree(node):
	if(randi() % 100 < item_drop_precent):
		var item: BaseItem = pick_item()
		item.position = node.position
		$Items.add_child(item)

func pick_item() -> BaseItem:
	var random = randi() % 100
	if(random < 50):
		return item_scenes[0].instantiate()
	return item_scenes[1].instantiate()


func _on_ball_speed_up():
	if ball_speed < ball_max_speed:
		ball_speed += ball_speed_up
	else:
		ball_speed = ball_max_speed
	
	
	print (ball_speed)
