class_name ManaDrawPile
extends Node2D


var draw_pile : Array[String] = []
@export var draw_pile_size : int
@export var red := 0
@export var blue := 0
@export var green := 0
@export var black := 0

func init():
	for i in red:
		draw_pile.append("red")
	for i in blue:
		draw_pile.append("blue")
	for i in green:
		draw_pile.append("green")
	for i in black:
		draw_pile.append("black")
	draw_pile.shuffle()
	draw_pile_size = len(draw_pile)

func draw():
	var value = draw_pile.pop_front()
	draw_pile_size -= 1
	return value

func refill():
	pass
