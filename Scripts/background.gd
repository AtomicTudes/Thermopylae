extends ParallaxBackground

@export var scroll_speed = 15
@export var bgtexture: CompressedTexture2D

@onready var sprite = $ParallaxLayer/Sprite2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	sprite.region_rect.position += delta * Vector2(scroll_speed, scroll_speed)
	if sprite.region_rect.position >= Vector2(128, 128):
		sprite.region_rect.position = Vector2.ZERO
