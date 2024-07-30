extends "res://Scripts/default_hoplite.gd"

class_name Enemy

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if health < 1:
		queue_free() #If troop is out of health, it dies

func _physics_process(delta):
	if is_on_floor():
		if foe_detector.is_colliding(): #Stuff to do if the troop sees an enemy
			if shield.has_overlapping_areas(): #What to do if the troop's shield is colliding with something (i.e. they're against an enemy)
				velocity.x = 0 #Stop moving
				animation_player.set_speed_scale(combatSpeed) #Set animation scales for the combat speed
				if animation_player.get_current_animation() == "marching":
					animation_player.play("RESET") #Interrupt the marching animation if it's happening
				if !animation_player.is_playing():
					attack() #Attack if nothing else is happening
			else: #If we see an enemy but we aren't in melee range, charge to the enemy
				velocity.x  = direction * SPEED * 2.0 #Increase movement speed
				animation_player.set_speed_scale(2.0) #Increase marching speed to match
				animation_player.queue("marching")
		else: #Stuff to do if the troop doesn't see an enemy
			if !animation_player.is_playing(): #Just march forward until we do.
				animation_player.play("marching")
				velocity.x = direction * SPEED
	elif not is_on_floor(): #If not on the floor, apply gravity to reach the floor.
		velocity.y += gravity * delta
		
	move_and_slide() #Actually moves the troop
