extends CharacterBody2D

@onready var foe_detector = $FoeDetector
@onready var torso = $Torso
@onready var head = $Torso/Head
@onready var animation_player = $AnimationPlayer

var troop_settings
var default_behavior

var direction = 1
var isEnemy = false
var collisionObjs = [] #A list of objects that will need their collision layer/mask changed depending on their team.

var moveSpeed = 150
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
	collisionObjs.append(self)
	equip(troop_settings)

func _process(delta):
	pass

func _physics_process(delta):
	if is_on_floor():
			#Sets the initial velocity for the troop based on its behavior.
			move_behavior()
			if lhequip.has_overlapping_areas():
				attack()
	elif not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()

#Determines the troop's behavior based on its settings. Basically, determines how it moves.
func move_behavior():
	if lhequip.has_overlapping_bodies():
		velocity.x = 0
		if torso.rotation != 0:
			#BUG: The troop 'snaps' into upright orientation as soon as contact is made, and that shouldn't really happen
			torso.rotation = 0
			head.rotation = -torso.rotation
	
	if default_behavior == "attack": #Basically just charges at the enemy
		if velocity.x == 0:
			velocity.x = direction * 5
		velocity.x += direction * absf(velocity.x) * 0.06 #This is acceleration, up to the troop's max move speed.
		velocity.x = clampf(velocity.x, -moveSpeed, moveSpeed)
		torso.rotation = 0.35 * direction * (velocity.x / moveSpeed) #The torso leans into the direction of the movement
		head.rotation = -torso.rotation #The head counters the torso's rotation to continue looking ahead.
	elif default_behavior == "defend": #Moves more slowly toward the enemy
		if velocity.x == 0:
			velocity.x = direction * 5
		velocity.x += direction * absf(velocity.x) * 0.06 #This is acceleration, up to the troop's max move speed.
		velocity.x = clampf(velocity.x, -moveSpeed / 2, moveSpeed / 2)
		torso.rotation = 0.35 * direction * (velocity.x / moveSpeed / 2) #The torso leans into the direction of the movement
		head.rotation = -torso.rotation #The head counters the torso's rotation to continue looking ahead.
	elif default_behavior == "support": #Tries to stand behind another troop
		pass
	elif default_behavior == "archer": #Stops and attempts to attack with a ranged weapon as soon as possible (work in progress)
		pass

#Equips each troop with specific stuff according to saved data.
func equip(troop_settings: DefaultTroop = DefaultTroop.new()):
	#Get the default behavior for the troop. Basically determines how it moves.
	default_behavior = troop_settings.default_behavior
	
	#equip on Right Hand.
	match troop_settings.weapon:
		"sword": rhequip = sword_scene.instantiate()
		"handaxe": rhequip = handaxe_scene.instantiate()
	get_node("Torso/R Upper Arm/R Lower Arm/R Hand").add_child(rhequip)
	rhequip.set_position(rhequip.spawnPos)
	collisionObjs.append(rhequip)
	
	#equip on Left Hand. Currently only equipping a shield
	get_node("Torso/L Upper Arm").set_rotation_degrees(10)
	get_node("Torso/L Upper Arm/L Lower Arm").set_rotation_degrees(-100)
	lhequip = shield_scene.instantiate()
	get_node("Torso/L Upper Arm/L Lower Arm/L Hand").add_child(lhequip)
	lhequip.set_position(Vector2(0, 4))
	collisionObjs.append(lhequip)
	
	#Change Sprite colors to match the saved data
	for each in get_tree().get_nodes_in_group("primary_color_nodes"):
		if self.is_ancestor_of(each):
			each.set_self_modulate(troop_settings["primary_color"])
	for each in get_tree().get_nodes_in_group("secondary_color_nodes"):
		if self.is_ancestor_of(each):
			each.set_self_modulate(troop_settings["secondary_color"])
	
	#scale *= 3 #ALERT Increase the scale for now, because I'm tired of squinting

#Inverts the team selection. Troops are spawned as allies by default.
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

#Starts the attack animation. Called by the physics process after checking the sprite's position.
func attack(): 
	if not animation_player.is_playing():
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
