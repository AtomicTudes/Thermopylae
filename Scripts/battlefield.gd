extends Node2D

@onready var ally_group = $Allies
@onready var enemy_group = $Enemies

var enemy_script = preload("res://Scripts/enemy.gd")
var ally_script = preload("res://Scripts/ally.gd")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_spawner_enemy_spawned(troop):
	troop.set_script(enemy_script)
	enemy_group.add_child(troop) #Each troop's _ready function is called when they're added to the scene
	troop.changeTeams()

func _on_spawner_ally_spawned(troop):
	troop.set_script(ally_script)
	ally_group.add_child(troop)
