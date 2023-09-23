extends KinematicBody2D

#onready var ui = get_viewport().get_node("Root/UI/Control") # ссылка на интерфейс

# Declare member variables here. Examples:
var speed= 300

onready var hp = 100
export var max_hp = 100
#onready var inventory1 = $Inventory
var dead = false

#var data_other:Dictionary
#var url_data:String

# Called when the node enters the scene tree for the first time.
func _ready():
	set_start_hp(hp, max_hp)
	add_to_group(Global_DataParser.entity_group)
#	add_to_group(Global_DataParser.animal_group)
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
		self.dead = true
		get_parent().remove_child(self)
		queue_free()

		
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



func reduce_hp(val):
	if self.hp > 0:
		self.hp -= val
#		print("Healt -= %s" % val)
#		print(hp)
	if self.hp > 0:
		update_hp()
	if self.hp <= 0:
		die()
		return false
	return true

func toggle_hp_bar_hide():
#	print("HP bar hide")
	$HP_bar.visible = false


func toggle_hp_bar():
	$HP_bar.visible = !$HP_bar.visible

func add_npc_on_location(npc):
		if  Global_DataParser.location_number == 1:
			$'/root/Game/Empire'.add_child(npc)
		elif  Global_DataParser.location_number == 2:
			$'/root/Game/Dark'.add_child(npc)
		elif  Global_DataParser.location_number == 3:
			$'/root/Game/Neutral'.add_child(npc)
#		else:
#			get_parent().get_node("Chat").get_node("Panel").get_node("RichTextLabel").text += "Failure. I can not do it here!\n"			
