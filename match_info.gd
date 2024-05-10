class_name Match_Info
extends Node

var lanes := [[null,null,null],[null,null,null]] 
@export var lane_names := [[null,null,null],[null,null,null]]
@export var network : Node
@export var matchNode : Match

@export var banned_cards := [null,null]

func is_lane_empty(player_num : int,lane_num : int) -> bool:
	return lanes[player_num-1][lane_num] == null

func add_card_to_match(card : Card,team : int,lane : int):
	lanes[team][lane] = card
	lane_names[team][lane] = card.name
	card.player_owner = team
	card.lane = lane
	network.get_node("Cards").add_child(card,true)

func ban_card(card : Card,team : int):
	banned_cards[team] = card.name

func empty_lanes(player_num : int) -> Array:
	var output := []
	for i in 3:
		if lanes[player_num][i] == null:
			output.append(i)
	return output

func get_card_at_lane(team : int,lane : int):
	if not multiplayer.is_server():
		print_debug("you aren't supposed to have called this from the client")
	return lanes[team][lane]

func get_card_name_at_lane(team : int,lane : int):
	return lane_names[team][lane]


func has_card_deployed(team,cardIndex):
	for i in 3:
		var card = get_card_name_at_lane(team,i)
		if not card:
			continue
		if card.contains(matchNode.get_unit_from_index(cardIndex).name):
			return true
	return false

func is_card_banned(team : int,cardIndex):
	return banned_cards[team] == matchNode.get_unit_from_index(cardIndex).name
