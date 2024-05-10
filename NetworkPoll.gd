class_name NetworkPoll
extends Node

signal _input_confirmed

var currPlayerNum
var acceptableInput = {}
var confirmFunctions = []

@export var matchInfo : Match_Info

func remove_duplicates(arr: Array) -> Array:
	var dict := {}
	for a in arr:
		dict[a] = 1
	return dict.keys()

@rpc("any_peer")
func confirm_input(params):
	if GameManager.get_id_from_player_num(currPlayerNum) != multiplayer.get_remote_sender_id():
		_input_confirmed.emit({params = params,valid = false})
		return
	var hasFailed = false
	for confirmFunction in confirmFunctions:
		if not Callable(self,confirmFunction).call(params,acceptableInput):
			hasFailed = true
			break
	_input_confirmed.emit({params = params,valid = not hasFailed})

func confirm_lane_input(params,validInput):
	if not params.lanes:
		return false
	params.lanes = remove_duplicates(params.lanes)
	if len(params.lanes) != validInput.num_lanes:
		return false
	for lane in params.lanes:
		if not lane in validInput.lanes:
			return false
	return true

#CURRENTLY UNUSED
func confirm_mana_input(params : Dictionary,validInput):
	if not params.has('color_mana'):
		params.color_mana = 0
	if not params.has('wild_mana'):
		params.wild_mana = 0
	if not params.has('any_mana'):
		params.any_mana = 0
	return params.color_mana >= validInput.color_mana \
	and params.wild_mana >= validInput.wild_mana

func confirm_client_cards(params : Dictionary,validInput):
	if not params.has("selected_client_card"):
		return false
	var playerId = currPlayerNum
	if playerId == null:
		playerId = GameManager.get_own_player_num()
	if matchInfo.has_card_deployed(playerId,params.selected_client_card):
		return false
	if matchInfo.is_card_banned(playerId,params.selected_client_card):
		return false
	return true

func confirm_attack(params : Dictionary,validInput):
	pass

func reset():
	acceptableInput = {}
	confirmFunctions = []

func poll_player(playerNum):
	var is_valid = false
	currPlayerNum = playerNum
	var pId = GameManager.get_id_from_player_num(playerNum)
	var params
	while not is_valid:
		$ClientPolled.pollClient.rpc_id(pId,confirmFunctions,acceptableInput)
		params = await _input_confirmed
		is_valid = params.valid
	reset()
	return params.params

func poll_lanes(lanes,num_lanes):
	acceptableInput["lanes"] = lanes
	acceptableInput["num_lanes"] = num_lanes
	confirmFunctions.append("confirm_lane_input")

func poll_mana(color_mana,any_mana,wild_mana):
	acceptableInput["color_mana"] = color_mana
	acceptableInput["wild_mana"] = wild_mana
	acceptableInput["any_mana"] = any_mana
	confirmFunctions.append("confirm_mana_input")

func poll_client_cards():
	acceptableInput["client_cards"] = true
	confirmFunctions.append("confirm_client_cards")

func poll_card_attacks():
	acceptableInput["attack"] = true
	confirmFunctions.append("confirm_attack")
