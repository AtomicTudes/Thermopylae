extends Node2D

@onready var ally_group = $Allies
@onready var enemy_group = $Enemies
@onready var allySpawn = $Spawner/AllySpawnPos
@onready var enemySpawn = $Spawner/EnemySpawnPos
@onready var allyTimer = $Spawner/AllyTimer
@onready var enemyTimer = $Spawner/EnemyTimer
@onready var data_manager = get_node("/root/data_manager")

@onready var ui = $ui
@onready var gold_counter = $ui/upper_ribbon/gold_icon/gold_text

var ally_troop_scene = preload("res://scenes/hoplite_32.tscn")
var enemy_troop_scene = preload("res://scenes/hoplite_32.tscn")
var allyIndex = 0
var enemy_spawn_min: int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	allyTimer.timeout.connect(on_ally_spawned)
	enemyTimer.timeout.connect(on_enemy_spawned)
	gold_counter.text = String.num(data_manager.player_info.gold)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if allyTimer.is_stopped() and ally_group.get_child_count() == 0:
		data_manager.save_game()
		await get_tree().create_timer(1.5).timeout
		ui.get_node("game_over").visible = true
		

func on_ally_spawned():
	var troopObj = data_manager.troop_dict[data_manager.deploy_order[allyIndex]]
	var new_troop = ally_troop_scene.instantiate()
	new_troop.troop_settings = troopObj
	ally_group.add_child(new_troop)
	new_troop.global_position = allySpawn.global_position
	allyIndex += 1
	if allyIndex >= data_manager.deploy_order.size():
		allyTimer.stop()

func on_enemy_spawned():
	var ally_num = ally_group.get_child_count()
	if ally_num > 1 and ally_num > enemy_group.get_child_count():
		enemy_spawn_min = int(ally_num * 1.5)
	for x in enemy_spawn_min:
		var new_troop = enemy_troop_scene.instantiate()
		new_troop.troop_settings = DefaultTroop.new()
		enemy_group.add_child(new_troop)
		new_troop.global_position = enemySpawn.global_position
		new_troop.changeTeams()
		new_troop.enemy_died.connect(on_enemy_died)
		await get_tree().create_timer(0.2).timeout

func on_enemy_died(troop):
	data_manager.player_info.kills += 1
	data_manager.player_info.gold += 1
	gold_counter.text = String.num(data_manager.player_info.gold)


func _on_enemy_despawn_body_entered(body):
	body.queue_free() # Replace with function body.
