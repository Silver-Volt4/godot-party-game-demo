extends Node
class_name Player

signal connected
signal disconnected

var peer: WebSocketPeer
var peer_state: WebSocketPeer.State :
	set (new_state):
		if peer_state == new_state:
			return
		if new_state == WebSocketPeer.STATE_OPEN:
			self.connected.emit()
		elif new_state == WebSocketPeer.STATE_CLOSING:
			self.disconnected.emit()
		peer_state = new_state
var secret: String

func get_secret():
	return self.name

func _init(wsp: WebSocketPeer):
	self.peer = wsp
	InputEventAction

func _exit_tree():
	if self.peer and self.peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
		self.peer.close(1000, "Disconnected")
		Players.graveyard.append(self.peer)

func _on_message(message: Variant):
	pass # Must implement

func _process(delta):
	if peer_state != WebSocketPeer.STATE_CLOSED:
		peer.poll()
		peer_state = peer.get_ready_state()
		while peer.get_available_packet_count():
			var packet = peer.get_packet()
			if not peer.was_string_packet():
				continue
			var message = JSON.parse_string(packet.get_string_from_utf8())
			if message:
				_on_message(message)

func replace_client(wsp: WebSocketPeer):
	if self.peer and self.peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
		self.peer.close(1000, "User replaced")
		Players.graveyard.append(self.peer)
		self.peer = wsp
