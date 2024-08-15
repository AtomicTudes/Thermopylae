extends Button

signal active_troop(main_button)

var troopId
var isEmpty = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#Creates a new troop objext and saves it to the savegame file
func create_new_troop():
	var save_dict = {
		"weapon": "sword", #default value; could be changed
		"primary_color": Color.RED.to_html(), #TODO Program this based on user-selected default
		"secondary_color": Color.BLACK.to_html(), #TODO ^
		"icon": create_icon(),
		"row": 1, #TODO: Program this based on the row property (which will be assigned in the army management screen)
		"col": 1, #TODO ^
	}
	
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ_WRITE)
	var json_string = JSON.stringify(save_dict)
	
	save_file.seek_end(0)
	save_file.store_line(json_string)

#Creates an icon for the troop_selector button based on the default colors (selected by user)
func create_icon():
	var baseImg = load("res://Assets/Troops/Hoplite Default x64/Separated Body Parts/Head.png").get_image()
	var pcImg = load("res://Assets/Troops/Hoplite Default x64/Separated Body Parts/Team Colors/Head Primary.png").get_image()
	var scImg = load("res://Assets/Troops/Hoplite Default x64/Separated Body Parts/Team Colors/Head Secondary.png").get_image()
	#Recolors each pixel in the Primary Color/Secondary Color images to match the selected value. Feels horrendously clumsy
	for i in pcImg.get_width():
		for j in pcImg.get_height():
			if pcImg.get_pixel(i, j) == Color.WHITE:
				pcImg.set_pixel(i, j, Color.RED) #TODO Set these colors according to user-defined default settings
	for i in scImg.get_width():
		for j in scImg.get_height():
			if scImg.get_pixel(i, j) == Color.WHITE:
				scImg.set_pixel(i, j, Color.BLACK) #TODO: Set this color according to user-defined default settings.
	#Creates one image from three (base head, primary color, secondary color)
	baseImg.blend_rect(pcImg, Rect2i(0,0,16,20), Vector2i(0,0))
	baseImg.blend_rect(scImg, Rect2i(0,0,16,20), Vector2i(0,0))
	self.icon = ImageTexture.create_from_image(baseImg)
	return baseImg.get_data().hex_encode() #Returns the image as an encoded string for JSON stringification.

func _on_toggled(toggled_on):
	if toggled_on:
		active_troop.emit(self) #Sends a signal if the button is toggled on
