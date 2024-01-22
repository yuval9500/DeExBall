extends RigidBody2D
class_name BaseItem

@export var min_speed = 100
@export var max_speed = 500

@export var max_angle = 0.75

var item_pickup: String

func _ready():
	var direction = Vector2.UP.rotated(randf_range(-max_angle, max_angle)).normalized()
	var speed = randf_range(min_speed, max_speed)
	apply_central_impulse(direction * speed)

func _on_body_entered(body):
	if item_pickup in body:
		var item_func = Callable(body, item_pickup)
		item_func.call()
		queue_free()
