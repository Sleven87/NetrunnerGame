extends Node2D


const COLLISION_MASK_CARD = 1				#gives the cards a collision layer for raycasting
const COLLISION_MASK_CARD_SLOT = 2			#gives the card slot a collision layer for raycasting
const DEFAULT_CARD_MOVE_SPEED = 1


var screen_size								#determines the screen size for location of card hand calculations below
var card_being_dragged						#this checks if the player is holding left click on a card and holding it
var is_hovering_on_card						#this determines whether the mouse is hovering on a card or not
var player_hand_reference 					#this references the location of the players hand so that new cards know where to go

func _ready() -> void:							#code runs on game launch
	screen_size = get_viewport_rect().size		#reads the screen size from the system
	player_hand_reference = $"../PlayerHand"	#references the scene file that is player hand for later use
	$"../Input_Manager".connect("left_mouse_button_released", on_left_click_released)


func _process(_delta: float) -> void:			#process code, runs on every frame but spreads the frames by delta
	if card_being_dragged:						#function that is checking if there is a card being dragged, first by taking the  mouse position and then getting its global position from the system
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x, 0, screen_size.x), 		#using a vector 2 and calculating the mouse position this will clamp the cards inside the screen and will not let you drag them out of existence
			clamp(mouse_pos.y, 0, screen_size.y))


func start_drag(card):																	#function that determines what happens when a card is being dragged
	card_being_dragged = card															#specifies that its the raycasted card from above
	card.scale = Vector2(1, 1)															#scale the card on the x and y values (width and height, thats what Vector2 does) and change both values to 1. i.e resize the card to 1
	var card_slot_found = raycast_check_for_card_slot()									#creates a variable based on successful raycast checking if there is a card slot under the mouse
	if card_slot_found and card_slot_found.card_in_slot:								#uses the created variable and says, is there a card there?
		card_slot_found.card_in_slot = false											#if the card that was picked up, came from a card slot, then re-activate that card slot



func finish_drag():
	card_being_dragged.scale = Vector2(1.05, 1.05)
	var card_slot_found = raycast_check_for_card_slot()
	if card_slot_found and not card_slot_found.card_in_slot:
		#card dropped in empty slot
		card_being_dragged.position = card_slot_found.position
		#card_being_dragged.get_node("Area2D/collisionShape2D").disabled = true				#this will disable the ability to pick up the card if its dropped in a card slot, I have disabled this as I want to be able to move cards for now, I might change this, infact I probably will later.
		card_slot_found.card_in_slot = true
	else:
		player_hand_reference.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
	card_being_dragged = null



func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)


func on_left_click_released():
	if card_being_dragged:														#on the release of left click drop card
		finish_drag()


func on_hovered_over_card(card):
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)


func on_hovered_off_card(card):
	if !card_being_dragged:
		highlight_card(card, false)
		#check if hovered off card straight onto another card
		var new_card_hovered = raycast_check_for_card()
		if new_card_hovered:
			highlight_card(new_card_hovered, true)
		else:
			is_hovering_on_card = false

func highlight_card(card, hovered):
	if hovered:
		card.scale = Vector2(1.05, 1.05)
		card.z_index = 2
	else:
		card.scale = Vector2(1, 1)
		card.z_index = 1


func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null


func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return get_card_with_highest_z_index(result)
	return null


func get_card_with_highest_z_index(cards):
	#assume the first card in cards array has the highest z index
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	#loop through the rest of the cards chekcing for a higher z index
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card
