extends Node


@export var manaBag : Node
@export var mana_gem_resource : Resource

@export var mana_colors = []
var mana = []

func draw_mana(index : int):
	pass

func get_color_from_name(color_name : String):
	match color_name:
		"green": return Color(0,1,0)
		"black": return Color()
		"red": return Color(1,0,0)
		"blue": return Color(0,0,1)

func add_mana(mana_color : String):
	mana_colors.append(mana_color)
	var mana_gem = mana_gem_resource.instantiate() as Sprite2D
	var index : int = len(mana)
	mana_gem.position = Vector2(1000 + index * 200,450 + (index % 2)*50)
	mana.append(mana_gem)
	mana_gem.self_modulate = get_color_from_name(mana_color)
	add_child(mana_gem,true)
	print("added mana ",mana_color)



func refill():
	while len(mana_colors) < 4:
		#draw mana from the mana bag
		add_mana($"../ManaDraw".draw())
		pass
	print("done refilling!!")

func init():
	refill()
