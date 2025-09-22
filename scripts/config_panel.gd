extends MarginContainer

func _on_settings_button_pressed() -> void:
	visible = not visible
	%HelpPanel.visible = false
