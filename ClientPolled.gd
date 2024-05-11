class_name ClientPolled
extends Node

@export var clientCardNode : Node
@export var networkPoll : NetworkPoll
@export var network : Node

var client_cards : Array :
	get:
		client_cards = clientCardNode.get_child(GameManager.get_own_player_num()).get_children()
		return client_cards
var confirmFunctions
var selected := {}
var validInput
var currentGroupButtons : Array[GroupButton]
var is_polled := false

@rpc()
func pollClient(confFunctions,acceptableInput):
	reset(confFunctions,acceptableInput)
	if acceptableInput.has("client_cards"):
		pollClientCards()
	if acceptableInput.has("lanes"):
		pollLanes()
	if acceptableInput.has("attack"):
		print("not polling client cards yipee",acceptableInput)
		pollAttacks()
	
func pollClientCards():
	var clientCardGroupButton = GroupButton.generateButtonGroup()
	clientCardGroupButton.pressed.connect(selected_a_card)
	clientCardGroupButton.unpressed.connect(unselected_a_card)
	for card : Card in client_cards as Array[Card]:
		clientCardGroupButton.add(card.select_button)
	clientCardGroupButton.instantiate()
	currentGroupButtons.append(clientCardGroupButton)

func pollLanes():
	var laneGroupButton = GroupButton.generateButtonGroup()
	laneGroupButton.pressed.connect(selected_a_lane)
	laneGroupButton.unpressed.connect(unselected_a_lane)
	for lane : int in validInput.lanes:
		laneGroupButton.add(get_child(lane).select_button)
	laneGroupButton.instantiate()
	currentGroupButtons.append(laneGroupButton)

func pollAttacks():
	var attackButtonGroup = GroupButton.generateButtonGroup(2)
	for card : Card in network.get_node("Cards").get_children():
		if card.is_local_player_card():
			for attackButton in card.attack_buttons:
				attackButtonGroup.add(attackButton)
	attackButtonGroup.instantiate()
	currentGroupButtons.append(attackButtonGroup)

func reset(confFunctions,acceptableInput):
	selected = {}
	is_polled = true
	confirmFunctions = confFunctions
	validInput = acceptableInput

func finishedPoll():
	for groupButton in currentGroupButtons:
		groupButton.clear()
	currentGroupButtons = []

func selected_a_card(card : Card):
	selected.selected_client_card = card.index

func unselected_a_card(_card : Card):
	selected.erase("selected_client_card")

func selected_a_lane(card : Card):
	selected.lanes = [card.name.to_int()]

func unselected_a_lane(card : Card):
	selected.erase("lanes")

func client_confirm_input(params):
	return confirmFunctions.all(func(confirmFunction): return Callable(networkPoll,confirmFunction).call(params,validInput))

func confirm_button_pressed():
	if not is_polled:
		return
	if client_confirm_input(selected):
		networkPoll.confirm_input.rpc_id(1,selected)
		is_polled = false
		finishedPoll()
