extends KinematicBody2D

#onready var ui = get_viewport().get_node("Root/UI/Control") # ссылка на интерфейс

# Declare member variables here. Examples:
var speed= 300

onready var hp = 100
export var max_hp = 100
onready var mana = 10
export var max_mana = 10
#onready var inventory1 = $Inventory
var dead = false
var level = 0 #текущий уровень персонажа
var energy = 0 #энергия веры от существ
var expirience = 0 #набрано опыта на текущем уровне
var level_up = false
var level_exp = false
var exp_need = 100 # кол-во опыта, нужное для повыешения уровня
var speed_level = 1.4 # скорость набора опыта(коеффициент, насколько нужно больше опыта для след. уровня
var damage_power = 5 
#var data_other:Dictionary
#var url_data:String

# Called when the node enters the scene tree for the first time.
func _ready():
	set_start_hp(hp, max_hp)
	add_to_group(Global_DataParser.entity_group)
#	add_to_group(Global_DataParser.animal_group)
#	set_process(false)
#	set_process_input(false)
func get_name():
	return self.name
func set_start_hp(hp, max_hp):
#	print("start_hp")
#	$HP_bar.value = hp
#	$HP_bar.max_value = max_hp
	pass
		
func update_hp():
	$HP_bar.value = hp

func die():
	if self.dead == false:
#		randomize()
#		for i in inventory.get_items():
#		var x_coord = rand_range(-2, 2) * 10 + self.position.x
#		var y_coord = rand_range(-2, 2) * 10 + self.position.y
#		add_lying_item(x_coord, y_coord)
		get_parent().remove_child(self)
		queue_free()
		self.dead = true
		
#func add_lying_item(x, y):
#	var item_id1 = 3
#	rpc_spawn_storage_die(item_id1,x,y)
#	url_data = "res://Database//data_" + "bag" + "_" + "mob" + ".json"
#	data_other = {"inventory":{}} # create empty inventory
#	data_other = inventory1.inventory_add_item(item_id1,5,data_other) # add item to inventory
#	get_parent().rpc_spawn_storage(get_parent().get_node("NicknameLabel").text, data_other, get_parent().global_position, url_data)

func increase_hp(val):
	self.hp = min(self.hp + val, self.max_hp)
	update_hp()
#	print("increase hp. HP = %s" % self.hp)

func add_level(val):
	level += val
#	print("level up")
#	print(level)
	self.max_hp *= speed_level
	self.hp = self.max_hp
	update_hp()	
	level_up = true
	return level
	
func add_exp(val):
	var a = add_expirience(val)
#	print("expirience up")
#	print(expirience)
	level_exp = true	
	if	a >= exp_need:
		expirience = a - exp_need		
		add_level(1) # повышаем уровень персонажа
		up_power()
		up_exp_need(speed_level)
#		if expirience == 0:
#			return
#		else:
#			add_exp(exp_need)	
func up_exp_need(val):
	exp_need *= val
	return int(exp_need)

func up_power():
	hp = int(max_hp * 1.1)
	hp = max_hp
	max_mana = int(max_mana * 1.05)
	damage_power  = damage_power * 1.20 # повышаем характеристики персонажа


func add_expirience(val):
	expirience +=val
	return expirience


func toggle_hp_bar_hide():
#	print("HP bar hide")
	$HP_bar.visible = false


func toggle_hp_bar():
	$HP_bar.visible = !$HP_bar.visible
func get_data_all():
	var _new_data:Dictionary
#	for i in range (0, 20):
	_new_data["whoiam"] ="res://Scenes/AngryAnimal.tscn"
	_new_data["hp"] = self.hp 
	_new_data["max_hp"] = self.max_hp
	_new_data["mana"] = self.mana 
	_new_data["max_mana"] = self.max_mana 	 

	_new_data["level"] = self.level
	_new_data["damage_power"] = self.damage_power 
	_new_data["expirience"] = self.expirience 		
	_new_data["npc_god"] = self.npc_god
	_new_data["dead"] = self.dead 
	return _new_data
	
func set_data_all(_new_data):
	self.expirience  = _new_data["expirience"] 
	self.damage_power = _new_data["damage_power"] 
	self.mana  = _new_data["mana"] 
	self.max_mana = _new_data["max_mana"] 
	self.hp  = _new_data["hp"] 
	self.max_hp = _new_data["max_hp"] 


	self.level = _new_data["level"]
	self.npc_god  = _new_data["npc_god"]
	self.dead  = _new_data["dead"] 

