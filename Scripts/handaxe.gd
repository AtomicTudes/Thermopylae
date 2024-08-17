extends "res://scripts/weapon.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	cleave = 2
	dmgMin = 20
	dmgMax = 25
	attackTypes = ["chop"]
	spawnPos = Vector2(12, 5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
