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
	
	var new_scale_factor: float
	
	match OS.get_name():
		"Windows", "UWP", "Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			new_scale_factor = 1.0
		"macOS":
			new_scale_factor = DisplayServer.screen_get_dpi() / 160.0
	
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
	
	title_label.set_position(Vector2(20 * new_scale_factor, 20 * new_scale_factor))
	version_label.set_position(Vector2(20 * new_scale_factor, 80 * new_scale_factor))
	renderer_label.set_position(Vector2(20 * new_scale_factor, 105 * new_scale_factor))
	
	title_label.scale = Vector2(new_scale_factor, new_scale_factor)
	version_label.scale = Vector2(new_scale_factor, new_scale_factor)
	renderer_label.scale = Vector2(new_scale_factor, new_scale_factor)
	
	visible = true
	unresizable = true
	size = Vector2(300 * new_scale_factor, 200 * new_scale_factor)
	position = Vector2(get_parent().get_viewport().get_window().position.x + get_parent().get_viewport().get_window().size.x / 2.0 - size.x / 2.0,
		get_parent().get_viewport().get_window().position.y + get_parent().get_viewport().get_window().size.y / 2.0 - size.y / 2.0)
	title = "About"

func _process(_delta):
	if !has_focus():
		_on_close_requested()

func _on_close_requested():
	speakerview_node.handle_show_about_window()
