extends Area

const tag = "easter egg"
signal easter_egg()

func _ready():
	connect("body_entered", self, "_on_body_entered")
	visible = true
	
func _on_body_entered(body):
	if body is KinematicBody:
		if body.has_method("get_tag"):
			if body.get_tag() == "player":
				if not body.ghost:
					_on_easter_egg()
				else:
					queue_free()
		
func _on_easter_egg():
	emit_signal("easter_egg")
	print("\nhttps://www.youtube.com/channel/UCN5LNyWh4Zm4ToKgPvY96yA\n")
	queue_free()
	
func get_tag():
	return tag
