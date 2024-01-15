extends RigidBody2D

var player_collision_layer = 1

var player_pos: Vector2
var ball_pos: Vector2

signal ball_touch_player(ball_direction)

func _on_body_entered(body):
	if "hit" in body:
		body.hit()
	elif body.collision_layer == player_collision_layer:
		player_pos = body.global_position
		ball_pos = global_position
		var ball_direction = (ball_pos - player_pos).normalized()
		
		ball_touch_player.emit(ball_direction)
