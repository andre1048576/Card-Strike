extends Node


@export var manaBag : Node

@export var mana := []

func draw_mana(index : int):
	pass

func refill():
	while len(mana) < 4:
		#draw mana from the mana bag
		pass
