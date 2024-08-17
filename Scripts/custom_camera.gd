extends Control

@onready var game_view = get_viewport()

@export var scroll_speed = 25

# Called when the node enters the scene tree for the first time.
func _ready():
	game_view.canvas_transform.origin = Vector2(300, 0)
	print(game_view.canvas_transform)
	pass # Replace with function body.
	
#Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("left"):
		game_view.canvas_transform.origin.x += scroll_speed
	if Input.is_action_pressed("right"):
		game_view.canvas_transform.origin.x += -scroll_speed
	if Input.is_action_pressed("up"):
		game_view.canvas_transform.origin.y += scroll_speed
	if Input.is_action_pressed("down"):
		game_view.canvas_transform.origin.y += -scroll_speed
	
