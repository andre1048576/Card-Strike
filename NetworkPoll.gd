class_name NetworkPoll
extends Node

signal _input_confirmed

var currPlayerNum = -1 :
	get:
		if currPlayerNum == -1:
			currPlayerNum = GameManager.get_own_player_num()
		return currPlayerNum
var acceptableInput = {}
var confirmFunctions = []
var prePolledInput = {}

@export var clientPolled : ClientPolled

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
	var valid = confirmFunctions.all(func(confirmFunction): return Callable(self,confirmFunction).call(params,acceptableInput))
	_input_confirmed.emit({params = params,valid = valid})

func confirm_lane(params : Dictionary,validInput):
	if not params.has("lanes"):
		return false
	var lanes = remove_duplicates(params.lanes)
	if len(lanes) != validInput.num_lanes:
		return false
	for lane in lanes:
		if not lane in validInput.lanes:
			return false
	return true

func confirm_mana(params : Dictionary,validInput):
	if not params.has("mana_index"):
		return false
	var mana_indexes : Array = remove_duplicates(params.mana_index)
	for index : int in mana_indexes:
		if index < 0 or index > 4:
			return false
	var mana_pool : ManaPool = $"../Network/Mana/ManaPool"
	match len(mana_indexes):
		1: return mana_pool.mana_colors[mana_indexes[0]] == "black"
		2: return mana_indexes.all(func(index : int): return mana_pool.mana_colors[index] != "black")
		_: return false

func confirm_client_cards(params : Dictionary,validInput):
	if not params.has("selected_client_card"):
		return false
	var playerId = currPlayerNum
	if matchInfo.has_card_deployed(playerId,params.selected_client_card):
		return false
	if matchInfo.is_card_banned(playerId,params.selected_client_card):
		return false
	return true

func confirm_attack(params : Dictionary,validInput):
	pass

@rpc("call_local")
func visible_right_side(val : int):
	$"../Network/ClientCards".visible = (val == 0)
	$"../Network/Mana".visible = (val == 1)

func reset():
	acceptableInput = {}
	confirmFunctions = []
	prePolledInput = {}

func post_poll(params : Dictionary,pId):
	pass



func poll_player(playerNum):
	var is_valid = false
	currPlayerNum = playerNum
	var pId = GameManager.get_id_from_player_num(playerNum)
	var params
	while not is_valid:
		clientPolled.pollClient.rpc_id(pId,confirmFunctions,acceptableInput)
		params = await _input_confirmed
		is_valid = params.valid
	params.params.merge(prePolledInput)
	reset()
	post_poll(params.params,pId)
	return params.params

func poll_lanes(lanes,num_lanes):
	if len(lanes) == num_lanes:
		prePolledInput.lanes = lanes
		return
	acceptableInput["lanes"] = lanes
	acceptableInput["num_lanes"] = num_lanes
	confirmFunctions.append("confirm_lane")

func poll_mana():
	acceptableInput["mana"] = true
	confirmFunctions.append("confirm_mana")

func poll_client_cards():
	acceptableInput["client_cards"] = true
	confirmFunctions.append("confirm_client_cards")

func poll_card_attacks():
	acceptableInput["attack"] = true
	confirmFunctions.append("confirm_attack")
