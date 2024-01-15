extends BaseItem

func _on_body_entered(body):
	if "enter_shooting_mode" in body:
		body.enter_shooting_mode()
		queue_free()
