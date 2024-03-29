extends RigidBody2D

var player_collision_layer = 1
var border_collision_layer = 5

var touch_counter: int = 0

var player_pos: Vector2
var ball_pos: Vector2
var offset: Vector2 = Vector2(0, 15)

signal touch_player(ball_direction)
signal speed_up()

func _on_body_entered(body):
	if "hit" in body:
		body.hit()
	elif body.collision_layer == player_collision_layer:
		player_pos = body.global_position
		ball_pos = global_position
		var ball_direction = (ball_pos - player_pos - offset).normalized()
		
		touch_player.emit(ball_direction)
	
	if (touch_counter == 5):
		speed_up.emit()
		touch_counter = 0
	else:
		touch_counter += 1
