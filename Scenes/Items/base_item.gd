extends RigidBody2D
class_name BaseItem

func _on_body_entered(body):
	if body.collision_layer == 1:
		print("add signal dummy!")
