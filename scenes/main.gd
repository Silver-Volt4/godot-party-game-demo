extends Control

func _ready():
	Players.player_joined.connect(self.player_joined)
	$QRCodeImage.texture = ImageTexture.create_from_image(QR.new().get_image("http://" + Server.self_addr + ":" + str(Server.http_server.get_local_port())))

func player_joined(player: Player):
	print("Player joined: ", player)
	player.message.connect(self.message.bind(player))

func message(what, player: Player):
	print("New message: ", what)
