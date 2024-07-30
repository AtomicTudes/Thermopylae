extends Node2D

signal enemySpawned(troop)
signal allySpawned(troop)

var troop_scene = preload("res://Scenes/default_hoplite.tscn")

@onready var ally_spawn = $AllySpawnPos
@onready var enemy_spawn = $EnemySpawnPos

func _on_enemy_timer_timeout(): #When the timer ticks, add an enemy troop
	for x in 5: #Drops troops in squads of 5 right now. Arbitrary number.
		var troop = troop_scene.instantiate()
		troop.global_position = enemy_spawn.global_position
		emit_signal("enemySpawned", troop)
		await get_tree().create_timer(0.2).timeout #Need some kind of await function so the troops aren't spawned on top of each other.

func _on_ally_timer_timeout(): #When the timer ticks, add an ally troop
	for x in 5:
		var troop = troop_scene.instantiate()
		troop.global_position = ally_spawn.global_position
		emit_signal("allySpawned", troop)
		await get_tree().create_timer(0.2).timeout
