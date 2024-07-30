extends CharacterBody2D

@export var direction = 1
@export var health = 20

@onready var foe_detector = $FoeDetector
@onready var body_frame = $BodySprite
@onready var animation_player = $AnimationPlayer
@onready var r_hand = $BodySprite/RUpperArm/RLowerArm/RHand

var weapon_scene = preload("res://Scenes/sword.tscn")
var shield_scene = preload("res://Scenes/shield.tscn")
var shield
var weapon
var isEnemy = false
var maskObjs = [] #A list of objects that will need their masking changed depending on their team.

var SPEED = 150 #speed = 50 has been good for real time so far
var combatSpeed = 1.0 #Float value indicating combat speed. Used to modulate animation playback speed of combat animations.

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Create a Random Number Generator for damage
var rng = RandomNumberGenerator.new()

var foe

func _ready():
	maskObjs.append(get_node("."))
	#maskObjs.append(foe_detector)
	equip()
	get_node("BodySprite/PrimaryColor").set_self_modulate(Color(0, 0, 1.0, 1.0))
	get_node("BodySprite/PrimaryColor/SecondaryColor").set_self_modulate(Color(0.41, 0.41, 0.41, 1.0))

#func _process(delta):
	#if health < 1:
		#queue_free() #If troop are out of health, it dies
#
#func _physics_process(delta):
#
	#if is_on_floor():
		#if foe_detector.is_colliding() && !isEnemy: #Stuff to do if the troop sees an enemy
			#velocity.x = 0 #First, stop moving
			#if animation_player.current_animation != "brace" && body_frame.frame != 33:
				##Troop braces if it isn't already braced
				#animation_player.play("brace")
			#if !animation_player.is_playing() && weapon.has_overlapping_bodies():
				#var attackType = RandomNumberGenerator.new() #Choose a random attack type
				#attackType.randomize()
				##print(attackType)
				#match attackType.randi_range(1,2):
					#1:
						#animation_player.play("chop")
					#2:
						#animation_player.play("stab")
		#else: #Stuff to do if the troop doesn't see an enemy
			#if animation_player.current_animation != "brace" && body_frame.frame == 33:
				##Troop unbraces if it is exiting combat
				#animation_player.play_backwards("brace")
				#animation_player.queue("RESET")
			#if !animation_player.is_playing():
				#animation_player.play("marching")
				#velocity.x = direction * SPEED
		#if shield.has_overlapping_areas(): #Stop moving if a shield is intersecting with something
			#velocity.x = 0
	#elif not is_on_floor(): #If not on the floor, apply gravity to reach the floor.
		#velocity.y += gravity * delta
		#
	#move_and_slide() #Actually moves the troop

#Equips and positions a weapon to each troop. Currently only a sword, but this should choose from an array in the future.
func equip():
	#equip on Right Hand. Currently only equipping a sword
	weapon = weapon_scene.instantiate()
	r_hand.add_child(weapon)
	weapon.set_position(Vector2(7,2))
	maskObjs.append(weapon.get_node("."))
	
	#equip on Left Hand. Currently only equipping a shield
	get_node("BodySprite/LUpperArm").set_rotation_degrees(10)
	get_node("BodySprite/LUpperArm/LLowerArm").set_rotation_degrees(-100)
	shield = shield_scene.instantiate()
	get_node("BodySprite/LUpperArm/LLowerArm/LHand").add_child(shield)
	shield.set_position(Vector2(-1,2))
	maskObjs.append(shield)

#Flips the team setting for a troop. Mostly used when spawning
func changeTeams():
	isEnemy = !isEnemy
	direction *= -1 #Flips the troop's movement/facing direction
	set_scale(Vector2(direction, 1)) #Flips the sprite facing direction
	if (isEnemy): #Sets team settings for enemies
		set_collision_layer_value(3, true)
		set_collision_layer_value(2, false)
		shield.set_collision_layer_value(3, true)
		shield.set_collision_layer_value(2, false)
		for each in maskObjs:
			each.set_collision_mask_value(2, true)
			each.set_collision_mask_value(3, false)
		get_node("BodySprite/PrimaryColor").set_self_modulate(Color(0.13, 0.55, 0.13, 1.0))
		get_node("BodySprite/PrimaryColor/SecondaryColor").set_self_modulate(Color(0.99, 0.96, 0.90, 1.0))
	elif (!isEnemy): #Sets team settings for allies
		set_collision_layer_value(3, false)
		set_collision_layer_value(2, true)
		for each in maskObjs:
			each.set_collision_mask_value(2, false)
			each.set_collision_mask_value(3, true)

func attack(): #Starts the attack animation. Called during the physics process
	if weapon.has_overlapping_bodies():
		rng.randomize() #Is this necessary?
		animation_player.play(weapon.attackTypes[rng.randi_range(0, weapon.attackTypes.size() - 1)]) #Uses a random attack animation based on an array in the weapon's script

#Delivers damage according to weapon stats. Called during the animation player to make the damage happen with realistic timing.
func fight():
	var enemies = weapon.get_overlapping_bodies()
	if (enemies.size() == 0):
		pass #If there are no enemies in range, exit processing
		
	#Determine how many enemies will be hit by this attack
	var attacks = weapon.cleave #Get the weapon's cleave rating
	if (enemies.size() < attacks):
		attacks = enemies.size() #Reduce the number of attacks if necessary to avoid an out-of-bounds error
	
	for i in attacks:
		enemies[i].health -= rng.randi_range(weapon.dmgMin, weapon.dmgMax)
