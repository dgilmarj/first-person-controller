extends KinematicBody

export var tag = "default"

# instance ref variables
onready var my_camera = $support_cam/Camera
onready var ray_on_floor = $ray_on_floor

const GRAVITY = 9.8

var _mouse_relative_raw : Vector2 = Vector2.ZERO
var _mouse_relative_smooth : Vector2 = Vector2.ZERO
export(float, 0.1, 1.0, 0.1) var mouse_smooth : float = 1.0
export(float, 0.1, 1.0) var mouse_sensitivity = 0.3
var _rotation_speed = 20

export(float, 10.0, 50.0, 0.5) var base_speed = 11.0
export(float, 1.2, 3.0, 0.1) var sprint = 1.5
export(float, 10.0, 30.0, 0.5) var vertical_speed = 15.0
export(float, 10.0, 50.0, 0.5) var jump_height = 25.0
export(float, 1.0, 10.0, 0.5) var gravity_scale = 5.0
export(float, 10.0, 35.0) var max_slope_angle = 30.0

export(bool) var lock_jump_dir = false

export(bool) var ghost = false

var vertical_accel : float = 0.0

var direction : Vector3 = Vector3.ZERO
var _lock_direction : Vector3 = Vector3.ZERO

var jumping : bool = false
var _gravity_reset : float
var _sprint_velocity : float = 1.0

func _ready():
	my_camera.current = true
	ray_on_floor.enabled = true
	
	_gravity_reset = gravity_scale
	set_ghost(ghost)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	ray_on_floor.set_collision_mask(get_collision_mask())
	
	
func _physics_process(delta):
	
	# camera rotation
	_mouse_relative_smooth = lerp(_mouse_relative_smooth, _mouse_relative_raw, mouse_smooth)
	rotate_y(deg2rad(_rotation_speed) * - _mouse_relative_smooth.x * mouse_sensitivity * delta)
	my_camera.rotate_x(deg2rad(_rotation_speed) * - _mouse_relative_smooth.y * mouse_sensitivity * delta)
	my_camera.rotation.x = clamp(my_camera.rotation.x, deg2rad(-70), deg2rad(70))
	_mouse_relative_raw = Vector2.ZERO
	
	# physics and movement
	var on_floor_bool = ray_on_floor.is_colliding()
	
	vertical_accel -= GRAVITY * gravity_scale * delta
	
	direction = _get_input_dir(direction, on_floor_bool, ghost, 0.02)
	var velocity = direction.rotated(Vector3.UP, rotation.y) * base_speed
	velocity.y = vertical_accel
	velocity = _sprint_jump_fly(vertical_accel, on_floor_bool, ghost, velocity, lock_jump_dir)
	
	vertical_accel = move_and_slide(velocity, Vector3.UP, true, 2, deg2rad(max_slope_angle)).y
	
	
func _input(event):
	
	# use escape to alternate between mouse mode visible and captured
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		_mouse_relative_raw = event.relative
		
	if Input.is_action_pressed("ui_home"):
		set_ghost(!ghost)
	
	
func _sprint_jump_fly(v_accel : float, on_floor : bool, ghost_mode : bool, vel : Vector3 = Vector3.ZERO, lock_dir : bool = false):
	if ghost_mode:
		if Input.is_action_pressed("jump"):
			vel.y = vertical_speed
			
		elif Input.is_action_pressed("ctrl"):
			vel.y = -vertical_speed
			
		else:
			vel.y = 0
			
		if Input.is_action_pressed("lshift"):
			vel = Vector3(vel.x * sprint, vel.y, vel.z * sprint)
			
		return vel
	else:
		
		var m_vel = Vector2(vel.x,vel.z).length()
		if Input.is_action_pressed("lshift") and m_vel > 0.001:
			_sprint_velocity = lerp(_sprint_velocity, sprint, 0.01)
			vel = Vector3(vel.x * _sprint_velocity, vel.y, vel.z * _sprint_velocity)
		else:
			_sprint_velocity = lerp(_sprint_velocity, 1, 0.1)
		
		if lock_dir:
			if Input.is_action_just_pressed("jump") and on_floor:
				jumping = true
				v_accel = jump_height
				_lock_direction = Vector3(vel.x, v_accel, vel.z)
				
				return _lock_direction
			
			if jumping and not on_floor:
					_lock_direction.y = vel.y
					return _lock_direction
					
			elif on_floor and vel.y < 0:
				jumping = false
				
		else:
			
			if Input.is_action_just_pressed("jump") and on_floor:
				jumping = true
				v_accel = jump_height
				vel.y = v_accel
				return vel
			elif on_floor:
				jumping = false
				
	return vel
	
	
func _get_input_dir(vec_from : Vector3, on_floor : bool, ghost : bool, weight : float):
	var horizontal = Input.get_action_strength("right_axis") -  Input.get_action_strength("left_axis")
	var vertical = Input.get_action_strength("backward_axis") - Input.get_action_strength("forward_axis")
	var new_dir = Vector3(horizontal, 0, vertical).normalized()
	
	
	if ghost:
		return new_dir
	
	if vec_from.length() > new_dir.length():
		weight = 0.15
	if not on_floor:
		weight = 0.005
		
	return lerp(vec_from, new_dir, weight)
	
	
func set_ghost(value:bool):
	# change collision layer
	if value:
		set_collision_mask_bit(0, false)
		set_collision_mask_bit(2, false)
		set_collision_mask_bit(3, false)
		gravity_scale = 0
		ghost = value
	else:
		set_collision_mask_bit(0, true)
		set_collision_mask_bit(2, true)
		set_collision_mask_bit(3, true)
		gravity_scale = _gravity_reset
		ghost = value
	
	
func get_tag():
	return tag
