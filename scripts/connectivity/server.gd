extends Node

var self_addr: String
@onready var http_server = TCPServer.new()
@onready var websocket_server = TCPServer.new()

var clients = []

func find_port(server: TCPServer, port: int):
	while true:
		var e = server.listen(port)
		if e == OK:
			break
		assert(e == 22)
		port += 1 % 65535
	return port

func _ready():
	find_port(http_server, 12003)
	find_port(websocket_server, 12004)
	
	print("Listening on ", http_server.get_local_port())

func tcp_process(peer: StreamPeerTCP):
	if peer.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		var bytes = peer.get_available_bytes()
		if bytes > 0:
			var request = peer.get_utf8_string(bytes)
			handle_http(request, peer)
	elif peer.get_status() == StreamPeerTCP.STATUS_NONE:
		clients.erase(peer)

func _process(delta):
	while http_server.is_connection_available():
		clients.append(http_server.take_connection())
	
	for client in clients:
		tcp_process(client)
	
	while websocket_server.is_connection_available():
		Players.add_player(websocket_server.take_connection())

func get_file(path: String):
	if path.ends_with("/"):
		path += "index.html"
	var mimetype: String
	
	var ext = path.split("/")[-1].split(".")[-1]
	if ext == "html":
		mimetype = "text/html"
	elif ext == "js":
		mimetype = "text/javascript"
	elif ext == "css":
		mimetype = "text/css"
	elif ext == "png":
		mimetype = "text/png"
	elif ext == "jpg":
		mimetype = "text/jpeg"
	elif ext == "svg":
		mimetype = "image/svg+xml"
		
	return [FileAccess.get_file_as_bytes("res://controller" + path), mimetype]

func handle_http(string: String, peer: StreamPeerTCP):
	var split = string.split("\r\n")
	var main = split.slice(0, 1)[0].split(" ")
	
	if main[0] != "GET":
		peer.put_data("HTTP/1.1 405 Method Not Allowed\r\n".to_utf8_buffer())
		clients.erase(peer)
		return
	
	if main[1] == "/game":
		var port = str(websocket_server.get_local_port())
		peer.put_data("HTTP/1.1 200 OK\r\n".to_utf8_buffer())
		peer.put_data("Access-Control-Allow-Origin: *\r\n".to_utf8_buffer())
		peer.put_data(("Content-Length: %s\r\n" % len(port)).to_utf8_buffer())
		peer.put_data(("Content-Type: text/plain\r\n").to_utf8_buffer())
		peer.put_data("\r\n".to_utf8_buffer())
		peer.put_data(port.to_utf8_buffer())
		return
	
	var headers = split.slice(1)

	var read = get_file(main[1])
	var content = read[0]
	var mime = read[1]
	var length = len(content)
	if length > 0:
		peer.put_data("HTTP/1.1 200 OK\r\n".to_utf8_buffer())
		peer.put_data("Access-Control-Allow-Origin: *\r\n".to_utf8_buffer())
		peer.put_data(("Content-Length: %s\r\n" % length).to_utf8_buffer())
		peer.put_data(("Content-Type: %s\r\n" % mime).to_utf8_buffer())
		peer.put_data("\r\n".to_utf8_buffer())
		peer.put_data(content)
	else:
		peer.put_data("HTTP/1.1 404 Not Found\r\n".to_utf8_buffer())
		clients.erase(peer)
		return
