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
	client_cards = notNetwork.get_children()
	var clientCardGroupButton = GroupButton.new()
	clientCardGroupButton.pressed.connect(selected_a_card)
	clientCardGroupButton.unpressed.connect(unselected_a_card)
	for card : Card in client_cards as Array[Card]:
		clientCardGroupButton.add(card.get_selection_button())
	clientCardGroupButton.instantiate()
	currentGroupButtons.append(clientCardGroupButton)

func pollLanes():
	var laneGroupButton = GroupButton.new()
	laneGroupButton.pressed.connect(selected_a_lane)
	laneGroupButton.unpressed.connect(unselected_a_lane)
	for lane : int in validInput.lanes:
		laneGroupButton.add(get_child(lane).get_selection_button())
	laneGroupButton.instantiate()
	currentGroupButtons.append(laneGroupButton)

func buttongroup_clicked(pressed):
	print(pressed)

func finishedPoll():
	for groupButton in currentGroupButtons:
		groupButton.clear()
	currentGroupButtons = []

func pollAttacks():
	var attackButtonGroup = GroupButton.new()
	for card : Card in network.get_node("Cards").get_children():
		if card.is_local_player_card():
			for attackButton in card.get_attack_buttons():
				attackButtonGroup.add(attackButton)
	attackButtonGroup.instantiate()

func reset(confFunctions,acceptableInput):
	selected = {}
	is_polled = true
	confirmFunctions = confFunctions
	validInput = acceptableInput

func selected_a_card(card : Card):
	selected.selected_client_card = init_client_cards.find(card)

func unselected_a_card(_card : Card):
	selected.erase("selected_client_card")

func selected_a_lane(card : Card):
	selected.lanes = [card.name.to_int()]

func unselected_a_lane(card : Card):
	selected.erase("lanes")

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
		finishedPoll()
