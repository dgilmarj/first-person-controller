extends Spatial

export(Vector3) var reset_point = Vector3(0,30,0)

func _ready():
	$dead_front.connect("body_entered", self, "_on_dead_zone_entered")
	$dead_back.connect("body_entered", self, "_on_dead_zone_entered")
	$dead_right.connect("body_entered", self, "_on_dead_zone_entered")
	$dead_left.connect("body_entered", self, "_on_dead_zone_entered")
	$dead_top.connect("body_entered", self, "_on_dead_zone_entered")
	$dead_bottom.connect("body_entered", self, "_on_dead_zone_entered")
	
func _on_dead_zone_entered(body):
	body.translation = reset_point
