extends Window

var speakerview_node
var title_label
var version_label
var renderer_label

func _ready():
	speakerview_node = get_node("/root/SpeakerView")
	title_label = get_node("title")
	version_label = get_node("version")
	renderer_label = get_node("renderer")
	
	var renderer: String
	match speakerview_node.rendering_method:
		"forward_plus":
			renderer = "Forward"
		"mobile":
			renderer = "Mobile"
		"gl_compatibility":
			renderer = "Compatibility"
	
	title_label.text = "SpeakerView"
	version_label.text = "Version " + speakerview_node.APP_VERSION
	renderer_label.text = "Renderer " + renderer
	
	title_label.set_position(Vector2(20, 20))
	version_label.set_position(Vector2(20, 80))
	renderer_label.set_position(Vector2(20, 105))


func _process(delta):
	if !has_focus():
		_on_close_requested()

func _on_close_requested():
	speakerview_node.handle_show_about_window()
