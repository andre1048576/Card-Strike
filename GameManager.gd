extends Node

var players : Array[int] = []

func get_id_from_player_num(playerNum : int)-> int:
	return players[playerNum]

#returns -1 if a spectator
func get_player_num(pID : int) -> int:
	if pID == players[0]:
		return 0
	elif pID == players[1]:
		return 1
	return -1

func get_own_player_num() -> int:
	return get_player_num(multiplayer.get_unique_id())

func add_player(pID):
	players.append(pID)
