extends CharacterBody2D

@export var direction = 1
@export var health = 20

@onready var foe_detector = $FoeDetector
@onready var body_frame = $BodySprite
@onready var animation_player = $AnimationPlayer

var sword_scene = preload("res://Scenes/sword.tscn")
var handaxe_scene = preload("res://Scenes/handaxe.tscn")
var shield_scene = preload("res://Scenes/shield.tscn")
var isEnemy = false
var collisionObjs = [] #A list of objects that will need their collision layer/mask changed depending on their team.

#A list of baseline characteristics for the default troop. These shouldn't be changed, but should be modified according to specific troop traits
var moveSpeed = 150 #speed = 50 has been good for real time so far
var combatSpeed = 1.0 #Float value indicating combat speed. Used to modulate animation playback speed of combat animations.

#A list of traits specific to different troops
var level
var rank
var weapon
var shield
var primaryColor: Color
var secondaryColor: Color
var kills

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Create a Random Number Generator for damage
var rng = RandomNumberGenerator.new()

func _ready():
	collisionObjs.append(self)
	rng.randomize()
	#equip()

#Equips each troop with specific stuff according to saved data.
func equip(troop_settings):
	#equip on Right Hand.
	match troop_settings["weapon"]:
		"sword": weapon = sword_scene.instantiate()
		"handaxe": weapon = handaxe_scene.instantiate()
	get_node("BodySprite/RUpperArm/RLowerArm/RHand").add_child(weapon)
	weapon.set_position(weapon.spawnPos)
	collisionObjs.append(weapon)
	
	#equip on Left Hand. Currently only equipping a shield
	get_node("BodySprite/LUpperArm").set_rotation_degrees(10)
	get_node("BodySprite/LUpperArm/LLowerArm").set_rotation_degrees(-100)
	shield = shield_scene.instantiate()
	get_node("BodySprite/LUpperArm/LLowerArm/LHand").add_child(shield)
	shield.set_position(Vector2(-1,2))
	collisionObjs.append(shield)
	
	#Change Sprite colors to match the saved data
	for each in get_tree().get_nodes_in_group("primary_color_nodes"):
		each.set_self_modulate(troop_settings["primary_color"])
	for each in get_tree().get_nodes_in_group("secondary_color_nodes"):
		each.set_self_modulate(troop_settings["secondary_color"])
	
	scale *= 3 #Increase the scale for now, because I'm tired of squinting

#Flips the team setting for a troop. Mostly used when spawning
func changeTeams():
	isEnemy = !isEnemy
	direction *= -1 #Flips the troop's movement/facing direction
	scale.x *= direction #Flips the sprite facing direction
	
	#Inverts the masking for all identified collision nodes
	for each in collisionObjs:
		each.set_collision_mask_value(2, !each.get_collision_mask_value(2))
		each.set_collision_mask_value(3, !each.get_collision_mask_value(3))
		if not each is Weapon: #Weapons don't exist on a layer. Inverts all other nodes' layering. Excludes RayCast2D, and any others that don't have layers
			each.set_collision_layer_value(2, !each.get_collision_layer_value(2))
			each.set_collision_layer_value(3, !each.get_collision_layer_value(3))
	
	#TODO: Invert color scheme

func attack(): #Starts the attack animation. Called during the physics process
	if weapon.has_overlapping_bodies():
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
		if enemies[i].health < 0:
			kills += 1 #Add a kill to this unit's count. Used to calculate xp gain.

func save():
	var save_dict = {
		"weapon": weapon.name,
		"primary_color": primaryColor.to_html(),
		"secondary_color": secondaryColor.to_html(),
		"kills": kills
	}
