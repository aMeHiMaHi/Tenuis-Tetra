extends Node

func _on_button_button_down():
	self.get_child(0).visible = true

func _on_button_5_button_down():
	if OS.has_feature('JavaScript'):
		JavaScriptBridge.eval("window.open('https://youtu.be/BKvNBZy_oho', '_blank').focus()")
	else:
		OS.shell_open("https://youtu.be/BKvNBZy_oho")

func _on_texture_button_4_button_up():
	self.get_child(1).visible = false

func _on_button_4_button_down():
	self.get_child(1).visible = true

func _on_button_3_button_down():
	self.get_child(2).visible = true

func _on_exit_button_up():
	self.get_child(2).visible = false


func _on_x_button_down():
	if OS.has_feature('JavaScript'):
		JavaScriptBridge.eval("window.open('https://twitter.com/aMeHiMaHi', '_blank').focus()")
	else:
		OS.shell_open("https://twitter.com/aMeHiMaHi")

func _on_youtube_button_down():
	if OS.has_feature('JavaScript'):
		JavaScriptBridge.eval("window.open('https://www.youtube.com/@aMeHiMaHi', '_blank').focus()")
	else:
		OS.shell_open("https://www.youtube.com/@aMeHiMaHi")

func _on_steam_button_down():
	if OS.has_feature('JavaScript'):
		JavaScriptBridge.eval("window.open('https://store.steampowered.com/search/?publisher=aMeHiMaHi', '_blank').focus()")
	else:
		OS.shell_open("https://store.steampowered.com/search/?publisher=aMeHiMaHi")