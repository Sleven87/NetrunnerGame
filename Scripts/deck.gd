extends Node2D


const CARD_SCENE_PATH = "res://Scenes/card.tscn"
const CARD_DRAW_SPEED = .5


var player_deck = ["bank_job", "direct_access", "self_modifying_code"]
var card_database_reference

#called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_deck.shuffle()
	$RichTextLabel.text = str(player_deck.size())
	card_database_reference = preload("res://Scripts/card_database.gd")

func draw_card():
	var card_drawn_name = player_deck[0]
	player_deck.erase(card_drawn_name)
	
	#if player drew the last card in the deck, disable the deck
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false

	$RichTextLabel.text = str(player_deck.size())
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	var card_image_path = str("res://Assets/cards/" + card_drawn_name + "_card.png")
	new_card.get_node("Card_Image").texture = load(card_image_path)
	new_card.get_node("attack").text = str(card_database_reference.CARDS[card_drawn_name][0])
	new_card.get_node("health").text = str(card_database_reference.CARDS[card_drawn_name][1])
	$"../CardManager".add_child(new_card)
	new_card.name = "card"
	$"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
