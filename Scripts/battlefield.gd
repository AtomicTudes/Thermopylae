extends Node2D

@onready var ally_group = $Allies
@onready var enemy_group = $Enemies

var enemy_script = preload("res://Scripts/enemy.gd")
var ally_script = preload("res://Scripts/ally.gd")

var troop_settings

func _init():
	load_game()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_spawner_enemy_spawned(troop):
	troop.set_script(enemy_script)
	enemy_group.add_child(troop) #Each troop's _ready function is called when they're added to the scene
	troop.equip(troop_settings)
	troop.changeTeams()

func _on_spawner_ally_spawned(troop):
	troop.set_script(ally_script)
	ally_group.add_child(troop)
	troop.equip(troop_settings)

func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		print("No save file found.")
		return
	
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()
		
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		troop_settings = json.get_data()
