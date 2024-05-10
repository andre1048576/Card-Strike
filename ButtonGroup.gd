class_name GroupButton

var buttongroup := ButtonGroup.new()
var buttons : Array[CheckButton]= []
var selected : Card

signal pressed(card : Card)
signal unpressed(card : Card)

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
		button.set_pressed_no_signal(button == selected)
		button.button_group = buttongroup
		button.visible = true

func on_pressed(button : CheckButton):
	var card : Card = button.get_parent()
	if button.button_pressed:
		selected = card
		emit_signal("pressed",card)
	else:
		emit_signal("unpressed",card)

func clear():
	for button : CheckButton in buttons:
		button.set_pressed_no_signal(false)
		buttongroup = null
		button.visible = false
