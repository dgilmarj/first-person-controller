extends Spatial

onready var respawn_node = $respawn_points.get_children()
onready var default_respawn_point : Vector3 = get_node("default_respawn_point").translation
onready var respawn_effect = $respawn_effect

var respawn_points = []

func _ready():
	$dead_front.connect("body_entered", self, "_on_dead_zone_entered")
	$dead_back.connect("body_entered", self, "_on_dead_zone_entered")
	$dead_right.connect("body_entered", self, "_on_dead_zone_entered")
	$dead_left.connect("body_entered", self, "_on_dead_zone_entered")
	$dead_top.connect("body_entered", self, "_on_dead_zone_entered")
	$dead_bottom.connect("body_entered", self, "_on_dead_zone_entered")
	
	respawn_effect.visible = false
	
	for r_n in respawn_node:
		respawn_points.append(r_n.translation)
		
	randomize()
	respawn_points.shuffle()
	
	
func _on_dead_zone_entered(body):
	if body.has_method("get_tag"):
		var t = body.get_tag()
		if t == "player" and len(respawn_points) > 2:
			var r_num = randi()%len(respawn_points)
			body.translation = respawn_points[r_num]
			respawn_effect.translation = respawn_points[r_num]
			respawn_effect.get_node("AnimationPlayer").stop()
			respawn_effect.get_node("AnimationPlayer").play("respawn")
		else:
			body.translation = default_respawn_point
	else:
		body.translation = default_respawn_point
