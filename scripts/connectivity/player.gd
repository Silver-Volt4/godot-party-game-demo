extends "./player_base.gd"

# Game-specific logic should go here

signal message(msg)

var username: String

func _on_message(msg):
	message.emit(msg)
