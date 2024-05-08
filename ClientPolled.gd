extends Node

@export var notNetwork : Node
@export var networkPoll : NetworkPoll
@export var network : Node

var init_client_cards : Array

var client_cards : Array :
	set(new_value):
		if not client_cards:
			init_client_cards = new_value
		client_cards = new_value
var confirmFunctions
var selected := {}
var validInput

var is_polled := false

func _ready():
	notNetwork.child_entered_tree.connect(card_added)
	for node : Card in get_children():
		node.pressed.connect(selected_a_lane)

func card_added(card):
	card.pressed.connect(selected_a_card)

func selected_a_lane(card : Card):
	if selected.lanes.has(card.name.to_int()):
		unselected_a_lane(card)
		return
	selected.lanes.append(card.name.to_int())
	if len(selected.lanes) != validInput.num_lanes:
		return
	for lane_index in validInput.lanes:
		if lane_index in selected.lanes:
			continue
		get_child(lane_index).toggle_clickable(false)
		

func unselected_a_lane(card : Card):
	selected.lanes.erase(card.name.to_int())
	for lane_index in validInput.lanes:
		if lane_index in selected.lanes:
			continue
		get_child(lane_index).toggle_clickable(true)

@rpc()
func pollClient(confFunctions,acceptableInput):
	reset(confFunctions,acceptableInput)
	if acceptableInput.has("client_cards"):
		pollClientCards(confFunctions,acceptableInput)
	elif acceptableInput.has("attack"):
		print("not polling client cards yipee",acceptableInput)
		pollClientAttacks(confFunctions,acceptableInput)

func pollClientCards(_confFunctions,_acceptableInput):
	client_cards = notNetwork.get_children()
	selected.lanes = []
	for lane : int in validInput.lanes:
		get_child(lane).toggle_clickable(true)
	for card in client_cards as Array[Card]:
		card.toggle_clickable(true)

func finishedPollClientCards():
	for card : Card in get_children():
		card.toggle_clickable(false)
	init_client_cards[selected.selected_client_card].queue_free()

func pollClientAttacks(confFunctions,acceptableInput):
	for card : Card in network.get_node("Cards").get_children():
		card.toggle_attacks_clickable()

func reset(confFunctions,acceptableInput):
	selected = {}
	is_polled = true
	confirmFunctions = confFunctions
	validInput = acceptableInput

func selected_a_card(card : Card):
	if selected.has("selected_client_card"):
		if selected.selected_client_card == init_client_cards.find(card):
			unselected_a_card(card)
			return
	selected.selected_client_card = init_client_cards.find(card)
	for other_card : Card in client_cards:
		if other_card == card:
			continue
		other_card.toggle_clickable(false)

func unselected_a_card(_card : Card):
	selected.erase("selected_client_card")
	for other_card in client_cards:
		other_card.toggle_clickable(true)

func client_confirm_input(params):
	for confirmFunction in confirmFunctions:
		if not Callable(networkPoll,confirmFunction).call(params,validInput):
			return false
	return true

func confirm_button_pressed():
	if not is_polled:
		return
	if client_confirm_input(selected):
		networkPoll.confirm_input.rpc_id(1,selected)
		is_polled = false
		if validInput.has("client_cards"):
			finishedPollClientCards()
