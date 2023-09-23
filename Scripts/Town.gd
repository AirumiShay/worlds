extends Node2D
#Здание Хутор Town.tscn  в группе  shops

onready var _url_data:String = ""
onready var _data:Dictionary = Dictionary()
var _name:String

func _ready():
	set_process(false)
	set_process_input(false)
	Global_DataParser.build_capital += 1

	$TimerBegin.start(10)
	$Sprite.visible = true

sync func init(inventory:Control, name:String, data:Dictionary, spawn_position:Vector2, url_data:String = ""):
#	rpc("load_data", inventory, name, "Bag", data)
	_name = name
	_url_data = url_data
	_data = inventory.load_data(name, "Town")
	position = spawn_position


#func load_data(inventory:Control, filename:String, item_list_label:String = "Bag", data_player:Dictionary = Dictionary()) -> Dictionary:
##	if(item_list_label == "Bag"):
#	url_data = "res://Database//data_bag_" + filename + ".json"
#	data = Global_DataParser.load_data(url_data)
#	if ((data.empty() && item_list_label == "Bag" && !data_player.empty())):
#		Global_DataParser.write_data(url_data, data_player)
#		data = data_player
#	return data


func reload_data_by_inventory(inventory:Control) -> Dictionary:
	_data = inventory.load_data(_name, "Bag")
	return _data


func is_data_empty_by_inventory(inventory:Control) -> bool:
	return inventory.is_inventory_empty_by_data(_data)


func rpc_destroy_self():
#	return 1
	rpc("destroy_self")


sync func destroy_self() -> void:
	for child in get_children():
		if child.has_method('queue_free'):
			child.queue_free()
	Global_DataParser.delete_file(_url_data)


func _on_Timer_timeout():
#	print("Hutor life end!!!")
	rpc_destroy_self()
	get_parent().remove_child(self)
	queue_free()


func _on_TimerBegin_timeout():
	$Sprite.visible = false
