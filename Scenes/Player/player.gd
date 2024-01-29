extends CharacterBody2D

const minimum_x: float = 5
const maximum_x: float = 355

var is_dragging = false
var input_start_pos: Vector2
var input_cur_pos: Vector2
var input_distance: float
var player_start_pos: Vector2
var max_player_scale: float = 2
var min_player_scale: float = 0.25

@export var can_laser: bool = false

signal laser_fired(laser_positions: Array[Node])
signal activate_magnet
signal activate_boom
signal activate_slow_slow
signal activate_explode_mult
signal activate_penetrating_ball

func _ready():
	pass

func _unhandled_input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			is_dragging = true
			input_start_pos = event.position
			player_start_pos = global_position
		else:
			is_dragging = false
			input_distance = 0
	if event is InputEventScreenDrag:
		input_cur_pos = event.position
		input_distance = input_start_pos.x - input_cur_pos.x

func _process(_delta):
	if is_dragging:
		global_position.x = player_start_pos.x - input_distance
		keep_player_in_bounds()
		if can_laser:
			shoot_laser()

func keep_player_in_bounds():
	var right_point = $PlayerImage/LaserPositions/RightPoint.global_position.x
	var left_point = $PlayerImage/LaserPositions/LeftPoint.global_position.x
	
	if right_point > maximum_x:
		global_position.x = maximum_x - (right_point - global_position.x)
		input_start_pos = input_cur_pos
		player_start_pos = global_position
		
	if left_point < minimum_x:
		global_position.x = minimum_x - (left_point - global_position.x)
		input_start_pos = input_cur_pos
		player_start_pos = global_position

func shoot_laser():
	can_laser = false
	var positions = $PlayerImage/LaserPositions
	var laser_positions = positions.get_children()
	$LaserReloadTimer.start()
	play_laser_particles()
	laser_fired.emit(laser_positions)

func play_laser_particles():
	$PlayerImage/LaserPositions/LeftParticle.restart()
	$PlayerImage/LaserPositions/RightParticle.restart()

func _on_laser_reload_timer_timeout():
	can_laser = true

#Item Pickups

func laser_pickup():
	$PlayerImage.texture = load("res://Sprites/Player/PlayerLaser.png")
	$LaserReloadTimer.start()

func magnet_pickup():
	activate_magnet.emit()

func boom_pickup():
	activate_boom.emit()

func slow_slow_pickup():
	activate_slow_slow.emit()

func explode_mult_pickup():
	activate_explode_mult.emit()

func penetrating_ball_pickup():
	activate_penetrating_ball.emit()

func expand_player_pickup():
	if(scale.x >= 1):
		scale.x += 0.5
		if(scale.x > max_player_scale):
			scale.x = max_player_scale
	else:
		scale.x += 0.25

func shrink_player_pickup():
	if(scale.x > 1):
		scale.x -= 0.5
	else:
		scale.x -= 0.25
		if(scale.x < min_player_scale):
			scale.x = min_player_scale
