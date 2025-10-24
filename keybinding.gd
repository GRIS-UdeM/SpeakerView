@tool
extends HBoxContainer

## Replaces Ctrl and Alt with macos-specific symbols
## This will need to change if we add a keybinding that specifically
## uses Control instead of Cmd on MacOS
func macos_keybinding_substitutions(text):
	return text.replace("Ctrl", "⌘").replace("Alt", "⌥")

## This is the text variable that you can change in the editor. Use Windows/Linux
## Conventions (Ctrl, Alt, ...) and they will be translated to macOS translation
## in the displayed_keybinding_text variable.
@export var keybinding_text: String = "":
	set(text):
		keybinding_text = text
		if OS.get_name() == "macOS":
			displayed_keybinding_text = macos_keybinding_substitutions(text)
		else:
			displayed_keybinding_text = text
		update_label()

var displayed_keybinding_text

@export var help_text: String = "":
	set(text):
		help_text = text
		update_label()
	
func _ready():
	if get_tree().current_scene:
		get_tree().current_scene.ready.connect(_on_scenetree_ready)

func update_label() -> void:
	if get_node_or_null("keymargin/keytext"):
		$keymargin/keytext.text = " " + displayed_keybinding_text + " "
	if get_node_or_null("Label"):
		$Label.text = help_text

func _on_scenetree_ready():
	update_label()
