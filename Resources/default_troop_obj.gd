class_name DefaultTroop extends Object

#Variables that directly control how a troop looks or works in the world.
var weapon: String = "sword"
var primary_color: String = Color.CRIMSON.to_html()
var secondary_color: String = Color.DIM_GRAY.to_html()
var icon
var default_behavior: String = "attack"

#Variables for record-keeping and statistics. May have an indirect effect on how the troop interacts with the world.
var kills: int = 0
var id
var row: int
var col: int

func _init(data: Dictionary = {}):
	for each in data.keys():
		self[each] = data[each]
	if id == null:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		id = rng.randi()
	get_icon()

#Creates a dictionary of properties in this object that are relevant to saving the game file.
func _get_property_list():
	var properties = []
	properties.append({
		"id": id,
		"row": row,
		"col": col,
		"weapon": weapon,
		"primary_color": primary_color,
		"secondary_color": secondary_color,
		"icon": icon.get_image().get_data().hex_encode(),
	})
	return properties[0]

#Uses a troop's color information to create an icon
func get_icon():
	if typeof(icon) == TYPE_STRING && icon != null: #If 'icon' is of a string type, it's still encoded from JSON. Decode it and turn it into a usable texture
		icon = ImageTexture.create_from_image(Image.create_from_data(16, 20, false, Image.FORMAT_RGBA8, icon.hex_decode()))
		return icon
	#If 'icon' is not a string type, it's either already an Image Texture that needs to be redrawn or it doesn't exist yet.
	var helm = load("res://Assets/Troops/Hoplite Default x64/Separated Body Parts/Head.png").get_image()
	var pcImg = load("res://Assets/Troops/Hoplite Default x64/Separated Body Parts/Team Colors/Head Primary.png").get_image()
	var scImg = load("res://Assets/Troops/Hoplite Default x64/Separated Body Parts/Team Colors/Head Secondary.png").get_image()
	#Recolors each pixel in the Primary Color/Secondary Color images to match the selected value. Feels horrendously clumsy
	for i in pcImg.get_width():
		for j in pcImg.get_height():
			if pcImg.get_pixel(i, j) == Color.WHITE:
				pcImg.set_pixel(i, j, primary_color)
	for i in scImg.get_width():
		for j in scImg.get_height():
			if scImg.get_pixel(i, j) == Color.WHITE:
				scImg.set_pixel(i, j, secondary_color)
	#Creates one image from three (base head, primary color, secondary color)
	helm.blend_rect(pcImg, Rect2i(0,0,16,20), Vector2i(0,0))
	helm.blend_rect(scImg, Rect2i(0,0,16,20), Vector2i(0,0))
	icon = ImageTexture.create_from_image(helm)
	return icon #Returns the image as a usable texture
