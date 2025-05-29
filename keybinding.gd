@tool
extends HBoxContainer
@export var keybinding_text: String = "":
	set(text):
		keybinding_text = text
		update_label()

@export var help_text: String = "":
	set(text):
		help_text = text
		update_label()
	
func _ready():
	get_tree().current_scene.ready.connect(_on_scenetree_ready)

func update_label() -> void:
	if $keymargin/keytext:
		$keymargin/keytext.text = " " +keybinding_text + " "
	if $Label:
		$Label.text = help_text

func _on_scenetree_ready():
	update_label()
