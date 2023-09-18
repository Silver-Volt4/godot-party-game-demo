extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	var devices = IP.get_local_interfaces()
	for device in devices:
		for address in device.addresses:
			var ip = $IPScrollList/IPList/IP.duplicate()
			ip.get_node("IPDetails/Name").text = device.friendly
			ip.get_node("IPDetails/Address").text = address
			ip.pressed.connect(self.select_address.bind(address))
			ip.show()
			$IPScrollList/IPList.add_child(ip)

func select_address(address: String):
	Server.self_addr = address
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_custom_address_pressed():
	select_address($Address.text)
