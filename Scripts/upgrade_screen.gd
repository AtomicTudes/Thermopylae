extends Control

@onready var data_manager = get_node("/root/data_manager")
@onready var troop_profile = data_manager.current_troop

#TODO: Change the header above the Troop display to be a name, offer an edit and randomize button, and include a popup about it being the first time.
#TODO: Make the "play" button automatically save the game. If there isn't a save game on file, the button should "play." If there is, the button should go to the "Army"
#TODO: Make the save action overwrite information or add to it as appropriate

@onready var weapon_display = $"HBoxContainer/Right Panel/HBoxContainer/WeaponDisplay"
@onready var equipPos = $"HBoxContainer/Middle Panel/PreviewArea/test_soldier/Hips/Torso/R Upper Arm/R Lower Arm/R Hand"
@onready var troop = $"HBoxContainer/Middle Panel/PreviewArea/test_soldier"
@onready var pc_picker = $"HBoxContainer/Right Panel/PrimaryColorPicker"
@onready var sc_picker = $"HBoxContainer/Right Panel/SecondaryColorPicker"
@onready var next_button = $"HBoxContainer/Right Panel/NextButton"

var possibleWeapons = ["res://scenes/sword.tscn", "res://scenes/handaxe.tscn"]
var num = 0

var equippedWeapon
var pc_nodes
var sc_nodes

# Called when the node enters the scene tree for the first time.
func _ready():
	if not data_manager.has_save: #Assigns the troop to the first army position, only if there isn't a save file.
		troop_profile.row = 1
		troop_profile.col = 1
		next_button.text = "PLAY"
	
	#Sets the color of the color wheels to match the troop colors
	pc_picker.color = troop_profile["primary_color"]
	sc_picker.color = troop_profile["secondary_color"]
	
	#Sets the team colors according to the values preloaded in the color picker nodes
	pc_nodes = troop.get_tree().get_nodes_in_group("primary_color_nodes")
	sc_nodes = troop.get_tree().get_nodes_in_group("secondary_color_nodes")
	for each in pc_nodes:
		each.set_self_modulate(pc_picker.color)
	for each in sc_nodes:
		each.set_self_modulate(sc_picker.color)
		
	changeWeapon(troop_profile["weapon"]) #Sets a default weapon so Godot doesn't get angry

#Creates an icon of the troop helmet with appropriate colors to use in the Army Management screen
func create_icon():
	var baseImg = get_node("HBoxContainer/Middle Panel/PreviewArea/test_soldier/Hips/Torso/Head").texture.get_image()
	var pcImg = get_node("HBoxContainer/Middle Panel/PreviewArea/test_soldier/Hips/Torso/Head/Team Colors/Primary").texture.get_image()
	var scImg = get_node("HBoxContainer/Middle Panel/PreviewArea/test_soldier/Hips/Torso/Head/Team Colors/Secondary").texture.get_image()
	#Recolors each pixel in the Primary Color/Secondary Color images to match the selected value. Feels horrendously clumsy
	for i in pcImg.get_width():
		for j in pcImg.get_height():
			if pcImg.get_pixel(i, j) == Color.WHITE:
				pcImg.set_pixel(i, j, pc_picker.color)
	for i in scImg.get_width():
		for j in scImg.get_height():
			if scImg.get_pixel(i, j) == Color.WHITE:
				scImg.set_pixel(i, j, sc_picker.color)
	#Creates one image from three (base head, primary color, secondary color)
	baseImg.blend_rect(pcImg, Rect2i(0,0,16,20), Vector2i(0,0))
	baseImg.blend_rect(scImg, Rect2i(0,0,16,20), Vector2i(0,0))
	return baseImg.get_data().hex_encode() #Returns the image as an encoded string for JSON stringification.

func _on_weapon_prev_pressed():
	num -= 1
	if num < 0:
		num = possibleWeapons.size() - 1
	changeWeapon(num)

func _on_weapon_next_pressed():
	num += 1
	if num >= possibleWeapons.size():
		num = 0
	changeWeapon(num)

#Changes the weapon in the hand of the troop. Accepts a number or string as parameter.
#BUG The number index also needs to change to reflect the currently equipped weapon. Or just find another way to do it.
func changeWeapon(selection):
	for each in equipPos.get_children(): #Remove all previously equipped weapons
		each.queue_free()
	var wepToEquip = possibleWeapons[0] #Sets a default value that may be overwritten by the following code
	match typeof(selection):
		2: #If the provided argument is a number, find the weapon this way
			wepToEquip = possibleWeapons[selection]
		4: #If the argument is a string, find the weapon this way
			for each in possibleWeapons:
				if each.to_lower().contains(selection):
					wepToEquip = each
					break
	equippedWeapon = load(wepToEquip).instantiate()
	equipPos.add_child(equippedWeapon)
	equippedWeapon.position = equippedWeapon.spawnPos
	weapon_display.texture = equippedWeapon.get_node("Sprite2D").texture
	troop_profile["weapon"] = equippedWeapon.name #Updates the weapon on the troop profile

func _on_primary_color_picker_color_changed(color):
	for each in pc_nodes:
		each.set_self_modulate(color)

func _on_secondary_color_picker_color_changed(color):
	for each in sc_nodes:
		each.set_self_modulate(color)

#Saves the troop information with any changes in the upgrade screen.
#BUG This doesn't actually do anything right now, because the troop_profile variable references the troop_dict object
func _on_save_button_pressed():
	troop_profile["primary_color"] = pc_picker.color.to_html()
	troop_profile["secondary_color"] = sc_picker.color.to_html()
	troop_profile.get_icon()
	data_manager.save_troop(troop_profile) #Stores the modified object in the troop_dict

#TODO Add some buttons and mechanisms for continuing without saving, etc
func _on_next_button_pressed():
	var new_game = !data_manager.has_save
	_on_save_button_pressed() #Saves the current troop
	data_manager.save_game() #Saves the army composition to file
	if (new_game):
		data_manager.deploy_order.append(troop_profile.id)
		get_tree().change_scene_to_file("res://scenes/battlefield.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/army_management.tscn")
