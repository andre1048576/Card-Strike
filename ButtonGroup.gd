class_name GroupButton

var buttongroup := ButtonGroup.new()
var buttons := []
var selected : CheckButton

signal pressed(CheckButton)

func _init():
	buttongroup.pressed.connect(on_pressed)

func add(button : CheckButton):
	buttons.append(button)

func remove(button : CheckButton):
	assert(button in buttons,"button isn't in the buttons array")
	buttons.erase(button)

func instantiate():
	for button : CheckButton in buttons:
		button.set_pressed_no_signal(button == selected)
		button.button_group = buttongroup

func on_pressed(button : CheckButton):
	emit_signal("pressed",button)

func clear():
	pass
