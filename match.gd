class_name Match
extends Node2D

var units = [preload("res://Cards/thief.tscn"),\
preload("res://Cards/priest.tscn"),preload("res://Cards/warrior.tscn")\
,preload("res://Cards/wizard.tscn"),preload("res://Cards/defender.tscn"),preload("res://Cards/gunner.tscn")]

var cards = []

@export var match_info : Match_Info

var p1Mana = {}
var p2Mana = {}

@onready var network_poll := $NetworkPoll

func _ready():
	if !multiplayer.is_server():
		return
	#for i in 6:
		#var instance : Card = units[i].instantiate()
		#@warning_ignore("integer_division")
		#instance.position = Vector2(250+(i%3)*300,220 + 580*(i/3))
		#instance.name = str(randi_range(1,10000))
		#$Network.add_child(instance)
		#cards.append(instance)
	client_ready.rpc()
	var num := 0
	for i in 6:
		var available_lanes = match_info.empty_lanes(num)
		network_poll.poll_lanes(available_lanes,1)
		network_poll.poll_client_cards()
		@warning_ignore("confusable_local_declaration")
		var output = await network_poll.poll_player(num)
		match_info.add_card_to_match(units[output.selected_client_card].instantiate(),num,output.lanes[0])
		num = 1 - num
	network_poll.poll_card_attacks()
	var _output = await network_poll.poll_player(num)

@rpc()
func client_ready():
	for i in 6:
		var instance : Card = units[i].instantiate()
		@warning_ignore("integer_division")
		instance.position = Vector2(1209+(i%3)*280,295 + 375*(i/3))
		instance.name = str(randi_range(1,10000))
		$NotNetwork.add_child(instance)

func get_unit_from_index(index : int) -> Card:
	return units[index].instantiate()
