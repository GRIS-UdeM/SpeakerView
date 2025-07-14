# thanks https://github.com/adamviola/simple-free-look-camera/blob/master/camera.gd
extends Camera3D

# Modifier keys' speed multiplier
const SHIFT_MULTIPLIER = 2.5
const ALT_MULTIPLIER = 1.0 / SHIFT_MULTIPLIER


@export_range(0.0, 1.0) var sensitivity: float = 0.05

# Mouse state
var _mouse_impulse = Vector2(0.0, 0.0)
var _total_pitch = 0.0

# Movement state
var _direction = Vector3(0.0, 0.0, 0.0)
var _velocity = Vector3(0.0, 0.0, 0.0)
var _acceleration = 30
var _deceleration = -10
var _vel_multiplier = 16

# Keyboard state
var _w = false
var _s = false
var _a = false
var _d = false
var _q = false
var _e = false
var _shift = false
var _alt = false

# Mouse state
var _right_click_pressed = false
var _left_click_pressed = false
var _wheel_impulse = 0

func _ready():
	look_at(Vector3(0.0, 1.0, 0.0), Vector3(0, 1, 0))

func reset_position():
	global_position = Vector3(4,6,15.865)
	look_at(Vector3(0.0, 1.0, 0.0), Vector3(0, 1, 0))

func _unhandled_input(event):
	if not current:
		return
	# Receives mouse motion
	if event is InputEventMouseMotion:
		_mouse_impulse += event.relative

	# Receives mouse button input
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_RIGHT: # Only allows rotation if right click down
				_right_click_pressed = event.pressed
			MOUSE_BUTTON_LEFT:
				_left_click_pressed = event.pressed
			MOUSE_BUTTON_WHEEL_DOWN:
				_wheel_impulse +=5
			MOUSE_BUTTON_WHEEL_UP:
				_wheel_impulse -=5
	elif event is InputEventPanGesture:
		_wheel_impulse += event.delta.y


	# Receives key input
	if event is InputEventKey and not event.alt_pressed:
		match event.keycode:
			KEY_W:
				_w = event.pressed
			KEY_S:
				_s = event.pressed
			KEY_A:
				_a = event.pressed
			KEY_D:
				_d = event.pressed
			KEY_Q:
				_q = event.pressed
			KEY_E:
				_e = event.pressed
			KEY_SHIFT:
				_shift = event.pressed
			KEY_ALT:
				_alt = event.pressed
			KEY_R:
				reset_position()


# Updates mouselook and movement every frame
func _process(delta):
	_update_mouselook()
	_update_movement(delta)

# Updates camera movement
func _update_movement(delta):
	# Computes desired direction from key states
	_direction = Vector3(
		(_d as float) - (_a as float),
		(_e as float) - (_q as float),
		(_s as float) - (_w as float)
	)
	# Computes the change in velocity due to desired direction and "drag"
	# The "drag" is a constant acceleration on the camera to bring it's velocity to 0
	var offset = _direction.normalized() * _acceleration * _vel_multiplier * delta \
		+ _velocity.normalized() * _deceleration * _vel_multiplier * delta

	offset.z += _wheel_impulse
	_wheel_impulse *= 0.8
	if abs(_wheel_impulse) < 0.1:
		_wheel_impulse = 0

	if _right_click_pressed:
		_mouse_impulse *= sensitivity
		offset.x += _mouse_impulse[0]
		offset.y -= _mouse_impulse[1]
	_mouse_impulse *= 0.8

	if abs(_mouse_impulse.length()) < 0.3:
		_mouse_impulse = Vector2.ZERO
	# Compute modifiers' speed multiplier
	var speed_multi = 1
	if _shift: speed_multi *= SHIFT_MULTIPLIER
	if _alt: speed_multi *= ALT_MULTIPLIER

	# Checks if we should bother translating the camera
	if (_direction == Vector3.ZERO and _wheel_impulse == 0 and _mouse_impulse == Vector2.ZERO) and offset.length_squared() > _velocity.length_squared():
		# Sets the velocity to 0 to prevent jittering due to imperfect deceleration
		_velocity = Vector3.ZERO
	else:
		# Clamps speed to stay within maximum value (_vel_multiplier)
		_velocity.x = clamp(_velocity.x + offset.x, -_vel_multiplier, _vel_multiplier)
		_velocity.y = clamp(_velocity.y + offset.y, -_vel_multiplier, _vel_multiplier)
		_velocity.z = clamp(_velocity.z + offset.z, -_vel_multiplier, _vel_multiplier)

		translate(_velocity * delta * speed_multi)

# Updates mouse look
func _update_mouselook():
	# Only rotates mouse if the mouse is captured
	if _left_click_pressed:
		_mouse_impulse *= sensitivity
		var yaw = _mouse_impulse.x
		var pitch = _mouse_impulse.y
		_mouse_impulse = Vector2(0, 0)

		# Prevents looking up/down too far
		pitch = clamp(pitch, -90 - _total_pitch, 90 - _total_pitch)
		_total_pitch += pitch

		rotate_y(deg_to_rad(-yaw))
		rotate_object_local(Vector3(1,0,0), deg_to_rad(-pitch))
