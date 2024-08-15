extends "res://Scripts/weapon.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	cleave = 1
	dmgMin = 0
	dmgMax = 0
	attackTypes = ["chop"]
	spawnPos = Vector2(12, 5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
