class_name Match
extends Node2D

var units : Array[Resource]= [preload("res://Cards/thief.tscn"),\
preload("res://Cards/priest.tscn"),preload("res://Cards/warrior.tscn")\
,preload("res://Cards/wizard.tscn"),preload("res://Cards/defender.tscn"),preload("res://Cards/gunner.tscn")]

var cards = []

@export var match_info : Match_Info

var p1Mana = {}
var p2Mana = {}

@export var network_poll : NetworkPoll
@export var client_cards : Node2D
@export var draw_pile : ManaDrawPile

func _ready():
	if !multiplayer.is_server():
		return
	client_init()
	server_init()
	await poll_delete_card(0)
	await poll_delete_card(1)
	for i in 3:
		await poll_add_card(0)
		await poll_add_card(1)
	$Network/Mana/ManaPool.init()
	await poll_mana(0)
	#network_poll.poll_card_attacks()
	#var _output = await network_poll.poll_player(playerNum)

func poll_delete_card(playerNum):
	network_poll.visible_right_side.rpc_id(GameManager.get_id_from_player_num(playerNum),0)
	network_poll.poll_client_cards()
	var output = await network_poll.poll_player(playerNum)
	match_info.banned_cards[playerNum] = units[output.selected_client_card].instantiate().name
	delete_client_card(playerNum,match_info.banned_cards[playerNum])

func poll_add_card(playerNum):
	network_poll.visible_right_side.rpc_id(GameManager.get_id_from_player_num(playerNum),0)
	var available_lanes = match_info.empty_lanes(playerNum)
	network_poll.poll_lanes(available_lanes,1)
	network_poll.poll_client_cards()
	var output = await network_poll.poll_player(playerNum)
	var card = units[output.selected_client_card].instantiate()
	delete_client_card(playerNum,card.name)
	match_info.add_card_to_match(card,playerNum,output.lanes[0])

func poll_mana(playerNum):
	network_poll.visible_right_side.rpc_id(GameManager.get_id_from_player_num(playerNum),1)
	network_poll.poll_mana()
	var output = await network_poll.poll_player(playerNum)
	#actually draw the mana
	print('card drawn')

func client_init():
	for pNum in 2:
		for i in 6:
			var instance : Card = units[i].instantiate()
			instance.index = i
			@warning_ignore("integer_division")
			instance.position = Vector2(1150+(i%3)*290,310 + 420*(i/3))
			instance.set_multiplayer_visibility_filter(func(pId):
				return GameManager.get_player_num(pId) == pNum)
			client_cards.get_child(pNum).add_child(instance)

func server_init():
	draw_pile.init()

func delete_client_card(pNum : int,cardName : String):
	client_cards.get_child(pNum).get_node(cardName).queue_free()

func get_unit_from_index(index : int) -> Card:
	return units[index].instantiate()
