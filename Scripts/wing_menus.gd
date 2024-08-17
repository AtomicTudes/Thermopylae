extends Control

@onready var edit_button = $RightGrid/EditButton


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func context_change(troopId):
	if troopId == null:
		edit_button.text = "RECRUIT"
	else:
		edit_button.text = "EDIT"
