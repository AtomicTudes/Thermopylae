extends "res://Scripts/weapon.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	cleave = 2
	dmgMin = 1
	dmgMax = 1
	attackTypes = ["chop", "stab"]
	spawnPos = Vector2(11, 3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
