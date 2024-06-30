extends Window

const MARGIN_SIZE = 20

var speakerview_node
var speakers_node
var fps_node
var vsync_node
var msaa_node
var spk_orientation_node
var columns_node


func _ready():
	speakerview_node = get_node("/root/SpeakerView")
	speakers_node = get_node("/root/SpeakerView/Speakers")
		
	var new_scale_factor: float = 1.0
	
	visible = true
	min_size = Vector2i(400, 180)
	size = Vector2(400 * new_scale_factor, 180 * new_scale_factor)
	position = Vector2(get_parent().get_viewport().get_window().position.x + get_parent().get_viewport().get_window().size.x / 2.0 - size.x / 2.0,
		get_parent().get_viewport().get_window().position.y + get_parent().get_viewport().get_window().size.y / 2.0 - size.y / 2.0)
	title = "Settings"

func _on_close_requested():
	if self in speakerview_node.get_children():
		speakerview_node.remove_child(self)


func _on_size_changed():
	speakerview_node = get_node("/root/SpeakerView")
	speakers_node = get_node("/root/SpeakerView/Speakers")
		
	vsync_node = $columns/options_row/Vsync
	fps_node = $columns/options_row/FPS
	msaa_node = $columns/options_row/MSAA
	spk_orientation_node = $columns/options_row/SpeakerOrientation
	columns_node = $columns
	
	columns_node.position = Vector2(MARGIN_SIZE, MARGIN_SIZE)
	columns_node.size = Vector2(size.x - 2 * MARGIN_SIZE, size.y + MARGIN_SIZE)
	
	vsync_node.button_pressed = DisplayServer.window_get_vsync_mode()
	
	fps_node.value = Engine.max_fps
	
	msaa_node.clear()
	for index in speakerview_node.msaa_3d.size():
		msaa_node.add_item(speakerview_node.msaa_3d[index][1])
		if speakerview_node.anti_aliasing in speakerview_node.msaa_3d[index]:
			msaa_node.select(index)
	
	spk_orientation_node.button_pressed = speakerview_node.spk_origin_orientation

func _on_fps_value_changed(value):
	Engine.max_fps = value
	speakerview_node.fps_max = str(value)

func _on_vsync_toggled(button_pressed):
	speakerview_node.vsync = button_pressed
	
	if button_pressed:# == DisplayServer.VSYNC_ENABLED:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _on_msaa_item_selected(index):
	var msaa_selected: Viewport.MSAA = speakerview_node.msaa_3d[index][0]
	speakerview_node.set_SV_anti_aliasing(msaa_selected)

func _on_speaker_orientation_toggled(button_pressed):
	print('_on_speaker_orientation_toggled')
	spk_orientation_node.button_pressed = button_pressed
	speakerview_node.spk_origin_orientation = button_pressed
	speakers_node.toggle_spk_orientation(button_pressed)
	
