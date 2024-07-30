extends "res://Scripts/default_hoplite.gd"

class_name Ally

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if health < 1:
		queue_free() #If troop is out of health, it dies

func _physics_process(delta):
	if is_on_floor():
		if foe_detector.get_collider() is Enemy || shield.has_overlapping_areas(): #Stuff to do if the troop sees an enemy
			velocity.x = 0 #First, stop moving
			if animation_player.current_animation != "brace" && body_frame.frame != 33:
				#Troop braces if it isn't already braced
				animation_player.play("brace")
			if !animation_player.is_playing() && weapon.has_overlapping_bodies():
				attack()
		else: #Stuff to do if the troop doesn't see an enemy
			if animation_player.current_animation != "brace" && body_frame.frame == 33:
				#Troop unbraces if it is exiting combat
				animation_player.play_backwards("brace")
				animation_player.queue("RESET")
			if !animation_player.is_playing():
				animation_player.play("marching")
				velocity.x = direction * SPEED
	elif not is_on_floor(): #If not on the floor, apply gravity to reach the floor.
		velocity.y += gravity * delta
		
	move_and_slide() #Actually moves the troop
