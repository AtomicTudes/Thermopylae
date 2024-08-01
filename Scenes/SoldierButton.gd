extends Button

@onready var edit_button = $EditButton
@onready var tree_button = $TreeButton

func _on_pressed():
	tree_button.disabled = false
	tree_button.visible = true
	edit_button.disabled = false
	edit_button.visible = true
