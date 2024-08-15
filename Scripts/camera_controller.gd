extends Camera2D

var scroll_speed = 25
var ui_elements
#@onready var camera = $Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("left"):
		position.x += -scroll_speed
	if Input.is_action_pressed("right"):
		position.x += scroll_speed
	if Input.is_action_pressed("up"):
		position.y += -scroll_speed
	if Input.is_action_pressed("down"):
		position.y += scroll_speed
	
	scale = Vector2(1 / zoom.x, 1 / zoom.y)
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom += Vector2(0.05, 0.05)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom += -Vector2(0.05, 0.05)
	zoom = zoom.clamp(Vector2(0.3, 0.3), Vector2(2.5, 2.5))
