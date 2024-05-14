class_name ManaPool
extends Node

@export var manaBag : ManaDrawPile
@export var mana_gem_resource : Resource

@export var mana_colors : Array = []
var mana = []

func get_color_from_name(color_name : String):
	match color_name:
		"green": return Color(0,1,0)
		"black": return Color()
		"red": return Color(1,0,0)
		"blue": return Color(0,0,1)

func add_mana(mana_color : String):
	mana_colors.append(mana_color)
	var mana_gem = mana_gem_resource.instantiate() as ManaGem
	var index : int = len(mana)
	mana_gem.position = Vector2(1100 + index * 100,450 + (index % 2)*50)
	mana_gem.color = mana_color
	mana_gem.index = index
	mana.append(mana_gem)
	mana_gem.self_modulate = get_color_from_name(mana_color)
	add_child(mana_gem,true)

func refill():
	while len(mana_colors) < 5:
		#draw mana from the mana bag
		add_mana(manaBag.draw())
		pass
	print("done refilling!!")

func draw(index : int):
	var mana_color = mana_colors.pop_at(index)
	refill()
	return 

func init():
	refill()
