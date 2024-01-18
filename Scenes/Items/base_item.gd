extends RigidBody2D
class_name BaseItem

@export var min_speed = 100
@export var max_speed = 500

@export var max_angle = 0.75

func _ready():
	var direction = Vector2.UP.rotated(randf_range(-max_angle, max_angle)).normalized()
	var speed = randf_range(min_speed, max_speed)
	apply_central_impulse(direction * speed)

func _on_body_entered(body):
	if body.collision_layer == 1:
		print("add signal dummy!")
