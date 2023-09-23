extends StaticBody2D

var dead = false

func get_data():
	var  _new_data = get_data_all()
	_new_data["positionX"] = self.position.x
	_new_data["positionY"] = self.position.y		
#	_new_data["whoiam"] ="res://Scenes/Build/Temple.tscn"
	_new_data["nickname"] ="WallGrane"
	return _new_data
func set_data(_new_data):
#	set_data_all(_new_data)
	self.dead = _new_data["dead"]	
func get_data_all():
	var _new_data:Dictionary
#	for i in range (0, 20):
	_new_data["whoiam"] ="res://Scenes/Walls/Grane.tscn"
#	_new_data["hp"] = self.hp 
#	_new_data["max_hp"] = self.max_hp
#	_new_data["mana"] = self.mana 
#	_new_data["max_mana"] = self.max_mana 	 

#	_new_data["level"] = self.level
#	_new_data["damage_power"] = self.damage_power 
#	_new_data["expirience"] = self.expirience 		
#	_new_data["npc_god"] = self.npc_god
	_new_data["dead"] = self.dead 
	return _new_data
	
#func set_data_all(_new_data):
#	self.expirience  = _new_data["expirience"] 
#	self.damage_power = _new_data["damage_power"] 
#	self.mana  = _new_data["mana"] 
#	self.max_mana = _new_data["max_mana"] 
#	self.hp  = _new_data["hp"] 
#	self.max_hp = _new_data["max_hp"] 
	
