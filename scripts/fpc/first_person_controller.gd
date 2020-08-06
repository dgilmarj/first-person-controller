extends KinematicBody

#instance ref variables
onready var my_camera = $Camera
onready var ray_on_floor = $ray_on_floor

const GRAVITY = 9.8

var mouse_relative_raw : Vector2 = Vector2.ZERO
var mouse_relative_smooth : Vector2 = Vector2.ZERO
export(float, 0.2, 1.0) var mouse_smooth : float = 1.0
export(float, 0.1, 1.0) var mouse_sensitivity = 0.3
var rotation_speed = 20

export(float, 20.0, 50.0, 0.5) var base_speed = 20.0
export(float, 10.0, 30.0, 0.5) var vertical_speed = 15.0
export(float, 10.0, 50.0, 0.5) var jump_height = 25.0
export(float, 1.0, 10.0, 0.5) var gravity_scale = 5.0

#cannot be changed at run time
export(bool) var ghost = false

var vertical_accel = 0.0

func _ready():
	my_camera.current = true
	ray_on_floor.enabled = true
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if ghost:
		$collider.disabled = true
		gravity_scale = 0
	
func _physics_process(delta):
	
	#camera rotation
	mouse_relative_smooth = lerp(mouse_relative_smooth, mouse_relative_raw, mouse_smooth)
	rotate_y(deg2rad(rotation_speed) * - mouse_relative_smooth.x * mouse_sensitivity * delta)
	my_camera.rotate_x(deg2rad(rotation_speed) * - mouse_relative_smooth.y * mouse_sensitivity * delta)
	my_camera.rotation.x = clamp(my_camera.rotation.x, deg2rad(-70), deg2rad(70))
	mouse_relative_raw = Vector2.ZERO
	
	#physics and movement
	vertical_accel -= GRAVITY * gravity_scale * delta
	var direction = Vector3(get_axis_strenght("horizontal"), 0, get_axis_strenght("vertical")).normalized()
	var velocity = direction.rotated(Vector3.UP, deg2rad(rotation_degrees.y)) * base_speed
	
	if not ghost and Input.is_action_just_pressed("jump") and ray_on_floor.is_colliding():
		vertical_accel = jump_height
	elif ghost and Input.is_action_pressed("jump"):
		vertical_accel = vertical_speed
	elif ghost and Input.is_action_pressed("ctrl"):
		vertical_accel = -vertical_speed
	elif ghost:
		vertical_accel = 0
		
	velocity.y = vertical_accel
	
	vertical_accel = move_and_slide(velocity).y
	
	
func _input(event):
	
	#use escape to alternate between mouse mode visible and captured
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		mouse_relative_raw = event.relative
		
func get_axis_strenght(axis_name : String = ""):
	
	if axis_name == "horizontal":
		return Input.get_action_strength("right_axis") - Input.get_action_strength("left_axis")
	elif axis_name == "vertical":
		return -Input.get_action_strength("forward_axis") + Input.get_action_strength("backward_axis")
		
	return 0
