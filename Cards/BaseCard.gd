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
		if is_local_player_card():
			position.y = 800
		else:
			position.y = 220

func is_local_player_card():
	return GameManager.get_own_player_num() == player_owner
	
func get_selection_button():
	return $SelectButton

#TODO: ensure the player has the mana to play the attacks
func get_attack_buttons():
	return attack_buttons.get_children()
