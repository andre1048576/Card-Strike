class_name Card
extends Sprite2D

@export var max_health : int
@export var player_owner := -1
@export var lane := -1 :
	set(new_lane):
		if new_lane < 0:
			return
		position.x = 250 + new_lane*300
		lane = new_lane

signal pressed()
signal attack_selected(card_index,attack_index)
signal attack_unselected(attack_index)

@onready var select_button := $SelectButton
@onready var heart_name := $HealthText
@onready var attack_buttons := $AttackButtons

var health : int :
	set(new_health):
		health = clampi(new_health,0,max_health)
		$HealthText.text = "[center]" + str(health)

func _ready():
	health = max_health
	if find_parent("Network") and not multiplayer.is_server():
		var isPlayerOwner = GameManager.get_own_player_num() == player_owner
		if isPlayerOwner:
			position.y = 800
		else:
			position.y = 220

func toggle_clickable(vis = not select_button.visible):
	select_button.visible = vis

func toggle_attacks_clickable(vis = not attack_buttons.visible):
	#TODO: check that the player owns the mana for the attack
	attack_buttons.visible = true

func _on_attack_pressed(attack_index : int):
	print('an attack was clicked!',attack_index)
	


func _on_select_button_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("pressed",self)

func _on_attack_button_input_event(viewport, event, shape_idx,attack_index : int):
	if event is InputEventMouseButton and event.pressed:
		_on_attack_pressed(attack_index)
