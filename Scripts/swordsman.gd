extends CharacterBody2D

@export var direction = 1
@export var health = 20

@onready var foe_detector = $FoeDetector
@onready var animation_player = $AnimationPlayer

const SPEED = 150
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Create a Random Number Generator for damage
var rng = RandomNumberGenerator.new()

var foe

func _on_ready():
	foe_detector.set_target_position(Vector2(200 * direction, 0))

func _process(delta):
	if health <= 0:
		queue_free()

func _physics_process(delta):
	
	if is_on_floor():
		if foe_detector.is_colliding():
			var tgtFoe = foe_detector.get_collider()
			#print ("Distance to enemy: " + str(tgtFoe.global_position.x - global_position.x))
			if tgtFoe.global_position.x - global_position.x < abs(25):
				velocity.x = 0
				if !animation_player.is_playing():
					foe = tgtFoe
					animation_player.play("stab")
			elif tgtFoe.global_position.x - global_position.x < abs(100):
				velocity.x = 0
			#else:
			#	velocity.x = direction * SPEED * 2
		else:
			velocity.x = direction * SPEED
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if velocity.x > 0:
		animation_player.play("march")
	
	move_and_slide()

func fight():
	if foe != null:
		var dmg = rng.randi_range(1, 4)
		foe.health -= dmg
		print("Hit monster for " + str(dmg))
