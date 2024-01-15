extends BaseItem

func _on_body_entered(body):
	if "magnet_pickup" in body:
		body.magnet_pickup()
		queue_free()
