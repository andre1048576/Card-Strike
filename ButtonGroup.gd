class_name GroupButton

var unpressedButtonGroup := ButtonGroup.new()
var pressedButtonGroup := ButtonGroup.new()
var buttons : Array[BaseButton]= []
var amount : int
var selection : Array[BaseButton]

signal pressed(control : Array[Node2D])
signal unpressed()

func _init():
	unpressedButtonGroup.pressed.connect(on_pressed)
	unpressedButtonGroup.allow_unpress = true
	pressedButtonGroup.pressed.connect(on_unpressed)
	pressedButtonGroup.allow_unpress = true

func add(button : BaseButton):
	buttons.append(button)

func remove(button : BaseButton):
	assert(button in buttons,"button isn't in the buttons array")
	buttons.erase(button)

func instantiate():
	for button : BaseButton in buttons:
		button.set_pressed_no_signal(false)
		button.button_group = unpressedButtonGroup
		button.visible = not fully_selected()
	for button : BaseButton in selection:
		button.set_pressed_no_signal(true)
		button.button_group = pressedButtonGroup
		button.visible = true

func on_pressed(button : BaseButton):
	selection.append(button)
	buttons.erase(button)
	if fully_selected():
		emit_signal("pressed",selection)
	instantiate()

func on_unpressed(button : BaseButton):
	if fully_selected():
		emit_signal("unpressed")
	selection.erase(button)
	buttons.append(button)
	instantiate()

func fully_selected():
	return len(selection) == amount

func clear():
	for button : BaseButton in buttons + selection:
		button.set_pressed_no_signal(false)
		button.visible = false
	unpressedButtonGroup = null
	pressedButtonGroup = null

static func generateButtonGroup(amount : int = 1) -> GroupButton:
	var buttongroup = GroupButton.new()
	buttongroup.amount = amount
	return buttongroup
