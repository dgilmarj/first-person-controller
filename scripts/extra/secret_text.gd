extends Label

var mess : String = "\n\n\nIt's not working yet :(\n\n\n\nFor more content:\n\nhttps://www.youtube.com/channel/UCN5LNyWh4Zm4ToKgPvY96yA\n\n\n\n"

var show_t = false

func _ready():
	set_process(false)
	set_process_input(false)
	set_physics_process(false)
	visible = false
	text = ""
	var item = get_parent().get_parent().get_node("object")
	var check = false
	if item != null:
		if item is Area:
			if item.has_method("get_tag"):
				var t = item.get_tag()
				if t == "easter egg":
					item.connect("easter_egg", self, "_print_secret")
					check = true
					
	if not check:
		queue_free()
	
	
func _process(delta):
	if show_t:
		var t = int(get_node("life_timer").time_left) + 1
		text = str(mess, t, "S\n\n")
			
func _print_secret():
	text = mess
	visible = true
	var t = Timer.new()
	t.wait_time = 10
	t.one_shot = true
	t.name = "life_timer"
	t.connect("timeout", self, "_life_time")
	add_child(t)
	t.start()
	show_t = true
	set_process(true)
	
func _life_time():
	visible = false
	queue_free()
	
