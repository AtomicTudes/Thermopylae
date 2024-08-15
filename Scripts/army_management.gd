extends Node2D

@onready var data_manager = get_node("/root/data_manager")
@onready var army = data_manager.troop_dict

@onready var troop_selector = preload("res://Scenes/troop_selector.tscn")
@onready var wing_menus = $wing_menus
@onready var ui = $ui

@onready var pyramid
@export var margin = 300

var current_button

# Called when the node enters the scene tree for the first time.
func _ready():
	setup_wing_menus()
	setup_ui()
	draw_pyramid()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#Creates the initial pyramid, given information from the troop dict
func draw_pyramid():
	if pyramid != null:
		await pyramid.queue_free()
	
	pyramid = Control.new()
	add_child(pyramid)
	pyramid.name = "pyramid"
	pyramid.position.y = 350
	pyramid.position.x = 1000
	
	for each in army:
		var rowNum = String.num(army[each].row)
		var row
		if pyramid.has_node("row_" + rowNum): #Gets a Node2D that acts as a marker for the row
			row = pyramid.get_node("row_" + rowNum)
		else: #If the row marker doesn't exist yet, creates one.
			row = Control.new()
			pyramid.add_child(row)
			if row.get_index() - 1 > army[each].row:
				pyramid.move_child(row, army[each].row)
			row.name = "row_" + rowNum
			row.position.y = pyramid.position.y - (margin * (row.get_index() + 1))
			#Adds a new blank menu item to occupy the 0th index in this row.
			create_blank_menu(row)
		#Adds a new menu item to this row, and fill in information about a troop as appropriate.
		var new_menu = create_blank_menu(row)
		new_menu.name = String.num(army[each].col)
		new_menu.icon = army[each].icon
		new_menu.troopId = army[each].id
		new_menu.isEmpty = false
		new_menu.position.x = ((margin * army[each].col) + (margin * (row.get_index() + 1) / 2)) * -1
		#Repositions the new troop in the scene tree, if possible.
		#Having the correct order in the tree is important, because the order of troop deployment during gameplay is based on the tree.
		var index = new_menu.get_index()
		if index > army[each].col:
			row.move_child(new_menu, army[each].col)
	#Adds a blank button to the end of each row. Having a leading and trailing blank item is important for calculating holes in the pyramid.
	for each in pyramid.get_children():
		create_blank_menu(each)
		
	check_pyramid_rows()

#Reviews the state of the pyramid to determine where the blank 'add troop' buttons should be visible
func check_pyramid_rows():
	#Figures out if we need to add another top row with a 'blank' troop indicator. Used if there are more than two people in the current highest row.
	var currentRow = pyramid.get_child(-1)
	if currentRow.get_child_count() > 3:
		var newRow = Control.new()
		pyramid.add_child(newRow)
		newRow.name = "row_" + String.num(pyramid.get_child_count())
		newRow.position.y = pyramid.position.y - (margin * (newRow.get_index() + 1))
		while newRow.get_child_count() < currentRow.get_child_count() - 1:
			create_blank_menu(newRow)
	var prevRowActiveCount
	#Checks each menu item in each row
	for row in pyramid.get_children():
		var rowIndex = row.get_index()
		#Creates additional blank menus so the current row always has one less child than the previous. NOTE:they might not all end up visible
		if not rowIndex == 0:
			while row.get_child_count() < pyramid.get_child(rowIndex - 1).get_child_count() - 1:
				create_blank_menu(row)
		var rowActiveCount = 2
		for menu in row.get_children():
			menu.visible = true #Sets all items visible. We'll turn some invisible later depending on conditions.
			if not menu.isEmpty:
				rowActiveCount += 1 #Increments the count if the menu item isn't empty
				#If the menu isn't empty, checks to make sure the tree index matches the col number. If not, assumes index < col and add blank troops until the two match
				if not army[menu.troopId].col == menu.get_index():
					while army[menu.troopId].col > menu.get_index():
						var blank_menu = create_blank_menu(row)
						row.move_child(blank_menu, menu.get_index())
						blank_menu.position.x = ((margin * blank_menu.get_index()) + (margin * (rowIndex + 1) / 2)) * -1
						menu.position.x = ((margin * menu.get_index()) + (margin * (rowIndex + 1) / 2)) * -1
			#If either of the menus directly beneath the current menu are empty, makes the menu invisible. The menu should already be blank.
			if rowIndex != 0 and (pyramid.get_child(rowIndex - 1).get_child(menu.get_index()).isEmpty or pyramid.get_child(rowIndex - 1).get_child(menu.get_index() + 1).isEmpty):
				menu.visible = false
		#After checking all the items in the row, compare the number of active items to those of the previous row. If the ratio is 1:2, make the empty items in the previous row invisible.
		#In other words, this keeps someone from adding a million troops at level one and never going to level two.
		if not rowIndex == 0:
			if prevRowActiveCount > 5 and (rowActiveCount * 10 / prevRowActiveCount) <= 5:
				for each in pyramid.get_child(rowIndex - 1).get_children():
					if each.isEmpty:
						each.visible = false
		prevRowActiveCount = rowActiveCount

#Creates a blank menu item in a provided row of the pyramid, positions it at the end of the row, then connects the signal to it.
func create_blank_menu(row):
	var blank_menu = troop_selector.instantiate()
	row.add_child(blank_menu)
	blank_menu.position.x = ((margin * blank_menu.get_index()) + (margin * (row.get_index() + 1) / 2)) * -1
	blank_menu.active_troop.connect(on_troop_selected)
	return blank_menu

#This happens when the 'recruit' button is pressed
func recruit_troop(menu):
	#Fills in the menu with troop information
	var troop = data_manager.create_troop_obj()
	menu.troopId = troop.id
	menu.isEmpty = false
	menu.icon = troop.icon
	var row = menu.get_parent()
	troop.row = row.get_index() + 1
	#If the troop was added to the front of the row, a new blank menu is inserted at the front of the row, menus are repositioned, and troop col numbers are reassigned.
	if menu.get_index() == 0:
		var blank_menu = create_blank_menu(row)
		row.move_child(blank_menu, 0)
		for each in row.get_children():
			each.position.x = ((margin * each.get_index()) + (margin * (row.get_index() + 1) / 2)) * -1
			if not each.isEmpty:
				army[each.troopId].col = each.get_index()
	#Other newly recruited troops are presumably in holes in the pyramid or at the end, so no other menus need to move
	else:
		troop.col = menu.get_index()
		menu.position.x = ((margin * menu.get_index()) + (margin * (row.get_index() + 1) / 2)) * -1
		#If the troop was added to the end of the row, adds a new blank menu at the end of the row
		if menu.get_index() + 1 == row.get_child_count():
			create_blank_menu(row)
	
	wing_menus.context_change(troop.id)
	check_pyramid_rows()

#Creates the troop deployment order based on the order of the pyramid. Returns an array.
func create_deployment_order():
	var deployment_order = []
	var pyramid_rows = pyramid.get_children()
	for i in pyramid_rows[0].get_child_count():
		var index = i
		for each in pyramid_rows:
			var menu = each.get_child(index)
			if not menu.isEmpty:
				deployment_order.append(menu.troopId)
			index -= 1
			if index < 0:
				break
	return deployment_order
	
#Connects signals from the wing menus to appropriate actions in the army manager
func setup_wing_menus():
	wing_menus.visible = false
	get_node("wing_menus/RightGrid/EditButton").pressed.connect(on_edit_pressed)

func setup_ui():
	get_node("ui/FightButton").pressed.connect(on_fight_pressed)
	
#When a new troop menu is toggled open, reposition the wing menus and target the new troop ID for operations
func on_troop_selected(new_button):
	if current_button == new_button:
		return #Has no effect if the troop is already selected
	if not current_button == null:
		current_button.button_pressed = false
	current_button = new_button #Sets the newly activated menu as the open one, so it can be toggled off next
	
	wing_menus.reparent(current_button, false)
	wing_menus.context_change(current_button.troopId) #Changes the state of the wing menus depending on the type of icon it's on (new vs. existing troop)
	wing_menus.visible = true

func on_edit_pressed():
	if current_button.troopId == null: #If the current button doesn't have an ID, it means no troop exists for it. We need to create one.
		recruit_troop(current_button)
	else:
		data_manager.current_troop = army[current_button.troopId]
		get_tree().change_scene_to_file("res://Scenes/upgrade_screen.tscn")

func on_fight_pressed():
	data_manager.save_game()
	data_manager.deploy_order = create_deployment_order()
	get_tree().change_scene_to_file("res://Scenes/battlefield.tscn")
