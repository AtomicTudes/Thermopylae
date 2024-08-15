extends Node

class_name DataManager

var troop_dict = {}
var player_info
var has_save
var current_troop = DefaultTroop.new()
var deploy_order = []

func _ready():
	load_game()

func test():
	var test = 0.59
	print(int(test * 10))

func save_test(item):
	var save_file = FileAccess.open("user://savetest.save", FileAccess.WRITE)
	var json_string = JSON.stringify(item)
	save_file.store_line(json_string)

func load_game():
	if not FileAccess.file_exists("user://savegame.save"): #Checks that the file exists, and returns if not.
		print("No save file found.")
		has_save = false
		player_info = { #Sets base values for a player profile
			"id": "player_info",
			"kills": 0,
			"iron": 0,
			"gold": 0,
		}
		return
	
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ) #Reads the file at the specified location.
	has_save = true
	while save_file.get_position() < save_file.get_length(): #For each line of data:
		var json_string = save_file.get_line()
		var json = JSON.new()
		
		var parse_result = json.parse(json_string) #Parses the string back into a dictionary
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		#ALERT the JSON reads a null line at the end of the file. Not sure if this is an issue?
		var data_line = json.get_data()
		match data_line["id"]: #Does different things with each data line depending on what it is.
			"player_info": #Saved player info (TODO still)
				player_info = data_line
			_: #Anything else should be the random number code of a specific troop profile, used to modify individual troops. These are added to the dictionary of army information.
				save_troop(DefaultTroop.new(data_line))

func save_game():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE) #This currently writes the save file from scratch every time. Works whether the file exists or not.
	
	var json_string = JSON.stringify(player_info)
	save_file.store_line(json_string)
	
	for each in troop_dict:
		var properties = troop_dict[each]._get_property_list()
		json_string = JSON.stringify(properties)
		save_file.store_line(json_string)
	
	has_save = true

#Appends a troop object to the troop dictionary, or overwrites it if the IDs match
func save_troop(troopObj):
	troop_dict[troopObj["id"]] = troopObj #This will automatically override a key or create a new one

#Takes the dictionary-type data from the JSON load, makes a new Object with the data, and adds it to the troop_dict collection. Also returns the troop ID and sets it as the active troop.
func load_troop_obj(data: Dictionary):
	var troopObj = DefaultTroop.new(data)
	save_troop(troopObj)

#Creates a new troop object from scratch and adds it to the troop dict. Returns the ID
func create_troop_obj():
	var troopObj = DefaultTroop.new()
	save_troop(troopObj)
	current_troop = troopObj
	return troopObj

func get_troop(troopId):
	if troop_dict.has(troopId):
		return troop_dict[troopId]
	else:
		return DefaultTroop.new()

##Uses a troop's color information to create an icon
#func create_icon(troopObj):
	#var helm = load("res://Assets/Troops/Hoplite Default x64/Separated Body Parts/Head.png").get_image()
	#var pcImg = load("res://Assets/Troops/Hoplite Default x64/Separated Body Parts/Team Colors/Head Primary.png").get_image()
	#var scImg = load("res://Assets/Troops/Hoplite Default x64/Separated Body Parts/Team Colors/Head Secondary.png").get_image()
	##Recolors each pixel in the Primary Color/Secondary Color images to match the selected value. Feels horrendously clumsy
	#for i in pcImg.get_width():
		#for j in pcImg.get_height():
			#if pcImg.get_pixel(i, j) == Color.WHITE:
				#pcImg.set_pixel(i, j, troopObj.primary_color)
	#for i in scImg.get_width():
		#for j in scImg.get_height():
			#if scImg.get_pixel(i, j) == Color.WHITE:
				#scImg.set_pixel(i, j, troopObj.secondary_color)
	##Creates one image from three (base head, primary color, secondary color)
	#helm.blend_rect(pcImg, Rect2i(0,0,16,20), Vector2i(0,0))
	#helm.blend_rect(scImg, Rect2i(0,0,16,20), Vector2i(0,0))
	#troopObj.icon = helm.get_data().hex_encode() #Sends the string representing this icon to the troop dict
	#return ImageTexture.create_from_image(helm) #Returns the image as a usable texture
