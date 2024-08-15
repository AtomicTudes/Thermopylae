extends Node2D

var sword_scene = preload("res://Scenes/sword.tscn")
var handaxe_scene = preload("res://Scenes/handaxe.tscn")

var possibleWeapons = [sword_scene, handaxe_scene]
var num = 0

@onready var base_button = $UI/PlayButton
@onready var equipPos = $"test_soldier/Hips/Torso/R Upper Arm/R Lower Arm/R Hand/WeaponEquip"

var equippedWeapon

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_left_button_pressed():
	num -= 1
	if num < 0:
		num = possibleWeapons.size() - 1
	changeWeapon(num)


func _on_right_button_pressed():
	num += 1
	if num >= possibleWeapons.size():
		num = 0
	changeWeapon(num)

func changeWeapon(num):
	for each in equipPos.get_children():
		each.queue_free()
	equippedWeapon = possibleWeapons[num].instantiate()
	equipPos.add_child(equippedWeapon)
	equippedWeapon.position = equippedWeapon.spawnPos
	base_button.icon = equippedWeapon.get_node("Sprite2D").texture


func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/battlefield.tscn")
