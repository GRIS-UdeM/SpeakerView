extends Button

func _ready():
	self.pressed.connect(_button_pressed)
	
func _button_pressed():
	get_node("/root/SpeakerView").switch_cameras()
