extends HBoxContainer

func _on_music_toggled(button_pressed):
	var i = AudioServer.get_bus_index('Music')
	AudioServer.set_bus_mute(i, button_pressed)


func _on_sound_toggled(button_pressed):
	var i = AudioServer.get_bus_index('Sounds')
	AudioServer.set_bus_mute(i, button_pressed)
