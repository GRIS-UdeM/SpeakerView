extends Camera360

var _a: bool = false
var _d: bool = false

func get_status_string():
	return "Fulldome Camera ({0}° FOV)".format([self.fovx])

func _unhandled_input(event):
	if not current:
		return
	# Receives key input
	if event is InputEventKey and not event.alt_pressed:
		match event.keycode:
			KEY_A:
				_a = event.pressed
			KEY_D:
				_d = event.pressed
			KEY_R:
				self.rotation.z = 0
			KEY_EQUAL, KEY_PLUS:
				if event.is_pressed():
					self.fovx += 10
					%CurrentCameraName.text = get_status_string()
			KEY_MINUS:
				if event.is_pressed():
					self.fovx -= 10
					%CurrentCameraName.text = get_status_string()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	var rotation = 0
	if _a:
		rotation = -1
	elif _d:
		rotation = 1
		
	self.rotation.z += delta * rotation
