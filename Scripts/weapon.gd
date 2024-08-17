extends Node

class_name Melee_Weapon

#Default values for calculating damage, no matter which weapon.
#Specific variables in specific weapon scenes should override?
var cleave = 1
var dmgMin = 1
var dmgMax = 2
var attackTypes = ["chop"]
var spawnPos = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func get_team():
	pass
