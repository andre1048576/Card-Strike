class_name ClientPolled
extends Node

@export var clientCardNode : Node
@export var networkPoll : NetworkPoll
@export var network : Node
@export var confirm_button : Button

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
	init_poll(confFunctions,acceptableInput)
	if acceptableInput.has("client_cards"):
		pollClientCards()
	if acceptableInput.has("lanes"):
		pollLanes()
	if acceptableInput.has("attack"):
		print("not polling client cards yipee",acceptableInput)
		pollAttacks()
	if acceptableInput.has("mana"):
		pollMana()
		print("mana polling time!")
	
func pollClientCards():
	var clientCardGroupButton = GroupButton.generateButtonGroup()
	clientCardGroupButton.pressed.connect(selected_a_card)
	clientCardGroupButton.unpressed.connect(unselected_a_card)
	for card : Card in client_cards as Array[Card]:
		clientCardGroupButton.add(card.select_button)
	clientCardGroupButton.instantiate()
	currentGroupButtons.append(clientCardGroupButton)

func pollLanes():
	var laneGroupButton = GroupButton.generateButtonGroup(validInput.num_lanes)
	laneGroupButton.pressed.connect(selected_a_lane)
	laneGroupButton.unpressed.connect(unselected_a_lane)
	for lane : int in validInput.lanes:
		laneGroupButton.add(get_child(lane).select_button)
	laneGroupButton.instantiate()
	currentGroupButtons.append(laneGroupButton)

func pollAttacks():
	var attackButtonGroup = GroupButton.generateButtonGroup()
	for card : Card in network.get_node("Cards").get_children():
		if card.is_local_player_card():
			for attackButton in card.attack_buttons:
				attackButtonGroup.add(attackButton)
	attackButtonGroup.instantiate()
	currentGroupButtons.append(attackButtonGroup)

func pollMana():
	var manaButtonGroup = ManaGroupButton.generateManaButtonGroup()
	manaButtonGroup.pressed.connect(selected_mana)
	manaButtonGroup.unpressed.connect(unselected_mana)
	for button in $"../../Network/Mana/ManaPool".get_children():
		if not button is ManaGem:
			continue
		manaButtonGroup.add(button)
	manaButtonGroup.instantiate()
	currentGroupButtons.append(manaButtonGroup)

func init_poll(confFunctions,acceptableInput):
	is_polled = true
	confirmFunctions = confFunctions
	validInput = acceptableInput

func reset():
	selected = {}
	confirm_button_visibility()

func finishedPoll():
	for groupButton in currentGroupButtons:
		groupButton.clear()
	currentGroupButtons = []
	reset()

func selected_a_card(cardGroup : Array[BaseButton]):
	selected.selected_client_card = cardGroup[0].get_parent().index
	confirm_button_visibility()

func unselected_a_card():
	selected.erase("selected_client_card")
	confirm_button_visibility()

func selected_a_lane(cardGroup : Array[BaseButton]):
	selected.lanes = cardGroup.map(func(button : BaseButton): return button.get_parent().name.to_int())
	confirm_button_visibility()

func unselected_a_lane():
	selected.erase("lanes")
	confirm_button_visibility()

func selected_mana(manaGroup : Array[BaseButton]):
	selected.mana_index = manaGroup.map(func(button : ManaGem): return button.index)
	confirm_button_visibility()

func unselected_mana():
	selected.erase("mana_index")
	confirm_button_visibility()

func confirm_button_visibility():
	confirm_button.visible = client_confirm_input(selected)

func client_confirm_input(params):
	return confirmFunctions.all(func(confirmFunction): return Callable(networkPoll,confirmFunction).call(params,validInput))

func confirm_button_pressed():
	if not is_polled:
		return
	networkPoll.confirm_input.rpc_id(1,selected)
	is_polled = false
	finishedPoll()
