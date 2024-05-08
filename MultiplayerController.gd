extends Node2D

@export var ADDRESS = "127.0.0.1"
@export var PORT = 8739
var peer
# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(player_connected)
	multiplayer.peer_disconnected.connect(player_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	pass # Replace with function body.

#server and clients
func player_connected(id):
	print("Player Connected " + str(id))
	
#server and clients
func player_disconnected(id):
	print("Player Disconnected " + str(id))

#client on connection
func connected_to_server():
	print("Connected to server")
	send_player_information.rpc_id(1,multiplayer.get_unique_id())

#client on disconnect
func connection_failed():
	print("Couldn't connect")

func host_game():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT,2)
	if error != OK:
		print("cannot host: " + error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	print('waiting 4 playrs')

@rpc("any_peer")
func send_player_information(id):
	if !GameManager.players.has(id):
		GameManager.add_player(id)
	if multiplayer.is_server():
		for i in GameManager.players:
			send_player_information.rpc(i)

@rpc("call_local")
func start_game():
	if len(multiplayer.get_peers()) < 2:
		print('not enough players!')
		return
	var scene = load("res://match.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()

func _on_host_button_down():
	host_game()

func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ADDRESS,PORT)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)


func _on_start_button_down():
	if len(multiplayer.get_peers()) < 2:
		print('not enough players!')
		return
	if multiplayer.is_server():
		start_game.rpc()
	else:
		_server_start_rpc.rpc_id(1)
	pass # Replace with function body.

@rpc("any_peer")
func _server_start_rpc():
	start_game.rpc()
