extends StaticBody2D
class_name BaseBlock

signal block_popped(position: Vector2)

func hit():
	block_popped.emit()
	queue_free()
