class_name ManaGroupButton
extends GroupButton

func instantiate():
	super()
	if len(selection) == 0:
		for button in buttons:
			button.disabled = false
	if len(selection) == 1 and not mana_is_black(selection[0]):
		for button in buttons:
			button.disabled = mana_is_black(button)

func on_pressed(button : BaseButton):
	var mana_button = button as ManaGem
	#check for if it's black mana
	print(mana_is_black(button), " pressed mana is black")
	if mana_is_black(button):
		amount = 1
	else:
		amount = 2
	super(button)

func mana_is_black(button : BaseButton):
	return button.color == "black"

static func generateManaButtonGroup() -> ManaGroupButton:
	var buttongroup = ManaGroupButton.new()
	buttongroup.amount = 2
	return buttongroup
