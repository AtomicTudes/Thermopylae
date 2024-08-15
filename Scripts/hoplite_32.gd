extends CharacterBody2D

@onready var foe_detector = $FoeDetector
@onready var body_frame = $Torso
@onready var animation_player = $AnimationPlayer

var direction = 1
var isEnemy = false
var collisionObjs = [] #A list of objects that will need their collision layer/mask changed depending on their team.

var moveSpeed = 100
var combatSpeed = 1.0

var sword_scene = preload("res://Scenes/sword.tscn")
var handaxe_scene = preload("res://Scenes/handaxe.tscn")
var shield_scene = preload("res://Scenes/shield.tscn")
var rhequip
var lhequip

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
# Create a Random Number Generator for damage
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

#Equips each troop with specific stuff according to saved data.
func equip(troop_settings: DefaultTroop = DefaultTroop.new()):
	#equip on Right Hand.
	match troop_settings.weapon:
		"sword": rhequip = sword_scene.instantiate()
		"handaxe": rhequip = handaxe_scene.instantiate()
	get_node("BodySprite/RUpperArm/RLowerArm/RHand").add_child(rhequip)
	rhequip.set_position(rhequip.spawnPos)
	collisionObjs.append(rhequip)
	
	#equip on Left Hand. Currently only equipping a shield
	get_node("BodySprite/LUpperArm").set_rotation_degrees(10)
	get_node("BodySprite/LUpperArm/LLowerArm").set_rotation_degrees(-100)
	lhequip = shield_scene.instantiate()
	get_node("BodySprite/LUpperArm/LLowerArm/LHand").add_child(lhequip)
	lhequip.set_position(Vector2(-1,2))
	collisionObjs.append(lhequip)
	
	#Change Sprite colors to match the saved data
	for each in get_tree().get_nodes_in_group("primary_color_nodes"):
		if self.is_ancestor_of(each):
			each.set_self_modulate(troop_settings["primary_color"])
	for each in get_tree().get_nodes_in_group("secondary_color_nodes"):
		if self.is_ancestor_of(each):
			each.set_self_modulate(troop_settings["secondary_color"])
	
	#scale *= 3 #ALERT Increase the scale for now, because I'm tired of squinting

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
	
	#TODO: Invert or otherwise change the color scheme

func attack(): #Starts the attack animation. Called during the physics process
	if rhequip.has_overlapping_bodies():
		animation_player.play(rhequip.attackTypes[rng.randi_range(0, rhequip.attackTypes.size() - 1)]) #Uses a random attack animation based on an array in the weapon's script

#Delivers damage according to weapon stats. Called during the animation player to make the damage happen with realistic timing.
func fight():
	var enemies = rhequip.get_overlapping_bodies()
	if (enemies.size() == 0):
		pass #If there are no enemies in range, exit processing
		
	#Determine how many enemies will be hit by this attack
	var attacks = rhequip.cleave #Get the weapon's cleave rating
	if (enemies.size() < attacks):
		attacks = enemies.size() #Reduce the number of attacks if necessary to avoid an out-of-bounds error
	
	for i in attacks:
		enemies[i].health -= rng.randi_range(rhequip.dmgMin, rhequip.dmgMax)
