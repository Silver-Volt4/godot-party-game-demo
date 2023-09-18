extends Node

signal player_joined(player)
signal player_connected(player)
signal player_disconnected(player)

@onready var PLAYER = preload("res://scripts/connectivity/player.gd")
@export var accepting_players = true

var graveyard = []
var awaiting = []

func get_uuid():
	var uuid = "%x" % randi()
	if not has_node(uuid):
		return uuid
	return get_uuid()

func add_player(peer: StreamPeerTCP):
	var wsp = WebSocketPeer.new()
	var e = wsp.accept_stream(peer)
	awaiting.append(wsp)

func handle_player(wsp: WebSocketPeer):
	var secret: String
	var url = wsp.get_requested_url()
	var split = url.split("#")
	
	if len(split) == 1 && accepting_players:
		secret = get_uuid()
		var p: Player = PLAYER.new(wsp)
		p.name = secret
		p.connected.connect(self.emit_signal.bind(&"player_connected", p))
		p.disconnected.connect(self.emit_signal.bind(&"player_disconnected", p))
		add_child(p)
		player_joined.emit(p)
		
	elif accepting_players:
		secret = split[1]
		if not has_node(secret):
			wsp.close(1000, "Cannot connect to non-existent user")
			graveyard.append(wsp)
			return
		var p: Player = get_node(secret)
		p.replace_client(wsp)
		
	else:
		wsp.close(1000, "This game has already begun.")

func _process(delta):
	for corpse in graveyard:
		corpse.poll()
		if corpse.get_ready_state() == WebSocketPeer.STATE_CLOSED:
			graveyard.erase(corpse)
	
	for player in awaiting:
		player.poll()
		if player.get_ready_state() == WebSocketPeer.STATE_OPEN:
			awaiting.erase(player)
			handle_player(player)
