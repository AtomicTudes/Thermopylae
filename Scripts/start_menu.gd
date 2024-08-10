extends Control

@onready var data_manager = get_node("/root/data_manager")

#TODO: Attempt to load a save file. If successful, open the army management screen. If not, open the upgrade troop screen and auto-populate a default troop.

func _on_start_button_pressed():
	if(data_manager.has_save): #If there's a savegame already on file, go to the Army Management screen
		get_tree().change_scene_to_file("res://Scenes/army_management.tscn")
	else: #If not, go to the Troop Upgrade screen
		get_tree().change_scene_to_file("res://Scenes/upgrade_screen.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
