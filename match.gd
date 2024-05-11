class_name Match
extends Node2D

var units : Array[Resource]= [preload("res://Cards/thief.tscn"),\
preload("res://Cards/priest.tscn"),preload("res://Cards/warrior.tscn")\
,preload("res://Cards/wizard.tscn"),preload("res://Cards/defender.tscn"),preload("res://Cards/gunner.tscn")]

var cards = []

@export var match_info : Match_Info

var p1Mana = {}
var p2Mana = {}

@onready var network_poll := $NetworkPoll
@onready var client_cards : Node2D = $Network/ClientCards
@onready var mana_nodes : Node2D = $Network/Mana

func _ready():
	if !multiplayer.is_server():
		return
	client_init.rpc()
	var playerNum := 0
	for i in 2:
		network_poll.poll_client_cards()
		var output = await network_poll.poll_player(playerNum)
		match_info.banned_cards[playerNum] = units[output.selected_client_card].instantiate().name
		playerNum = 1 - playerNum
	for i in 6:
		var available_lanes = match_info.empty_lanes(playerNum)
		network_poll.poll_lanes(available_lanes,1)
		network_poll.poll_client_cards()
		@warning_ignore("confusable_local_declaration")
		var output = await network_poll.poll_player(playerNum)
		match_info.add_card_to_match(units[output.selected_client_card].instantiate(),playerNum,output.lanes[0])
		playerNum = 1 - playerNum
	mana_visibility.rpc()
	network_poll.poll_card_attacks()
	var _output = await network_poll.poll_player(playerNum)

@rpc("call_local")
func client_init():
	for i in 6:
		var instance : Card = units[i].instantiate()
		instance.index = i
		@warning_ignore("integer_division")
		instance.position = Vector2(1209+(i%3)*280,295 + 375*(i/3))
		instance.name = str(randi_range(1,10000))
		client_cards.add_child(instance)

@rpc
func mana_visibility():
	client_cards.visible = false
	mana_nodes.visible = true

func get_unit_from_index(index : int) -> Card:
	return units[index].instantiate()
