class_name GroupButton

var buttongroup := ButtonGroup.new()
var buttons : Array[CheckButton]= []
var depth : int
var selection
#TODO: figure out how to add select

signal pressed(control : Node2D)
signal unpressed(control : Node2D)

func _init():
	buttongroup.pressed.connect(on_pressed)
	buttongroup.allow_unpress = true

func add(button : CheckButton):
	buttons.append(button)

func remove(button : CheckButton):
	assert(button in buttons,"button isn't in the buttons array")
	buttons.erase(button)

func instantiate():
	for button : CheckButton in buttons:
		button.set_pressed_no_signal(false)
		button.button_group = buttongroup
		button.visible = true

func on_pressed(button : CheckButton):
	selection = button
	for i in depth:
		selection = button.get_parent()
	if button.button_pressed:
		emit_signal("pressed",selection)
	else:
		emit_signal("unpressed",selection)
		selection = null

func clear():
	for button : CheckButton in buttons:
		button.set_pressed_no_signal(false)
		buttongroup = null
		button.visible = false

static func generateButtonGroup(depth : int = 1):
	var buttongroup = GroupButton.new()
	buttongroup.depth = depth
	return buttongroup
