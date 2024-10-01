extends Node

func _on_button_button_down():
	self.get_child(0).visible = true

func _on_button_5_button_down():
	OS.shell_open("https://www.youtube.com/watch?v=BKvNBZy_oho")

func _on_texture_button_4_button_up():
	self.get_child(1).visible = false

func _on_button_4_button_down():
	self.get_child(1).visible = true

func _on_button_3_button_down():
	self.get_child(2).visible = true

func _on_exit_button_up():
	self.get_child(2).visible = false
