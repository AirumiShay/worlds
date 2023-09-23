extends Node

onready var player_position = Vector2()
onready var player_position1 = Vector2()
onready var _player_name = "Anon"
onready var player_control = false # сейчас игрок управляет мобов или нпс-ом?
onready var world_already_load = true
onready var singleplay = false

#==================== from Stickman project
onready var entity_group = "ENTITY"
onready var animal_group = "ANIMALS"
#==================== from Stickman project
onready var darkempire_group = "darkempire"
onready var empire_group = "empire"
onready var neutral_group = "neutral"
onready var players_group = "players"
onready var boss_group = "boss"
onready var builds_group = "builds" #здания
onready var build_remove_group = "build_remove"
onready var build_repare_group = "build_repare"
onready var player_damage_group = "player_damage"
onready var unhole_ground_group = "unhole_ground"
onready var farm_group = "farm"
onready var location_number = 3
onready var location_id
var hardlevel = 0
#====================
var expirience = 0 #набрано опыта на текущем уровне
var level = 0 #текущий уровень персонажа
var energy = 0 #энергия веры от существ
var level_up = false
var level_exp = false
var exp_need = 100 # кол-во опыта, нужное для повышения уровня
var speed_level = 1.65 # скорость набора опыта(коеффициент, насколько нужно больше опыта для след. уровня
var kobold_count = 0 #всего родилось мобов кобольдов
var ork_count = 0 #всего родилось мобов орков
var magfire_count = 0 #всего родилось мобов магов огня
var paladin_count = 0 #всего родилось мобов паладинов
var darkelf_count = 0 #всего родилось мобов темных эльфов
var darkmag_count = 0 #всего родилось мобов темных эльфов
var cyclop_count = 0 #всего родилось мобов троллей
var ghost_count = 0 #всего родилось мобов призраков
var knight_count = 0 #всего родилось мобов рыцарей гномов
var knight_elite_count = 0 #всего родилось мобов гномов элитных  рыцарей
var vampire_count = 0 #всего родилось мобов вампиров
var vampire_elite_count = 0 #всего родилось высших вампиров
var peasant_count = 0 #всего родилось мобов крестьян
var zombie_count = 0 #всего родилось мобов зомби
var elf_count = 0 #всего родилось мобов  эльфов
var animal_count = 0 #всего родилось мобов животных
#====================
var build_farm = 0 # сколько всего построено хуторов Империи
var build_village = 0 # сколько всего построено поселков Империи
var build_temple = 0 # сколько всего построено храмов Империи
var build_castle = 0 # сколько всего построено замков Империи
var build_capital = 0 # сколько всего построено столиц Империи
var build_fortress = 0 # сколько всего построено крепостей Империи
var build_barrack = 0 # сколько всего построено бараков Империи
var build_storage = 0 # сколько всего построено кладбищ Империи
var build_magtower = 0 # сколько всего построено бараков Империи
var build_castle_vampire = 0 # сколько всего построено замков вампиров
var build_fortress_dark = 0 # сколько всего построено крепостей Темной Империи
var build_avanpost_dark = 0 # сколько всего построено аванпостов Темной Империи
var build_farm_vampire = 0 # сколько всего построено хуторов Империи
#====================
var _new_data = {
		"Empire":[],
		"DarkEmpire":[],
		"Neutral":[],
		"Animal":[]			
	}

#const
var IS_LOAD_FROM_FILE_ENABLED = false # true - load/save data from/to outside executable .json files, false - use only variables
onready var join_race = 1

var file:File

onready var rng = RandomNumberGenerator.new()
onready var DEFAULT_IP = '127.0.0.1'

onready var data_global:Dictionary = { "res://Database//items.json":
	{	"inventory": {
			"0": {
				"name": "",
				"icon": "res://Assets/Images/Items/empty_slot.png",
				"type": "misc",
				"weight": 0.0,
				"stackable": false,
				"stack_limit": 1,
				"description": "",
				"sell_price": 0
			},
			
			"1": {
				"name": "Foods",
				"icon": "res://Sprites/misc/food.png",
				"type": "food",
				"weight": 0.01,
				"stackable": true,
				"stack_limit": 9999999,
				"description": "Use it as cash or food.",
				"sell_price": 1
			},

			"2": {
				"name": "Golden Coin",
				"icon": "res://Assets/misc/golden_coin.png",
				"type": "coin",
				"weight": 0.001,
				"stackable": true,
				"stack_limit": 999999999,
				"description": "Golden Coin",
				"sell_price": 1,
				},
		
			"3": {
				"name": "Water bottle",
				"icon": "res://Sprites/misc/potion.png",
				"type": "water",
				"weight": 1,
				"stackable": true,
				"stack_limit": 9999999,
				"description": "Potion full of life water.\n Restore health on time, or 50% now",
				"sell_price": 1
			},
		
			"4": {
				"name": "Flask for mana",
				"icon": "res://Sprites/misc/flask.png",
				"type": "water",
				"weight": 1,
				"stackable": true,
				"stack_limit": 9999999,
				"description": "Flask full of mana.\n Restore mana on time, or 50% now",
				"sell_price": 3
			},
		
			"5": {
				"name": "Good dagger",
				"icon": "res://Sprites/misc/dagger.png",
				"type": "weapon",
				"weight": 0.5,
				"stackable": true,
				"stack_limit": 9999999,
				"description": "Good basic dagger. 2-5 damage",
				"sell_price": 5,
				"damage": 5,
			},

		
			"7": {
				"name": "town",
				"icon": "res://Assets/build/hutor_blue.png",
				"type": "build",
				"weight": 0.01,
				"stackable": true,
				"stack_limit": 9999999,
				"description": "Scroll: Basic settlement\n for 12 inhabitants",
				"sell_price": 1000
				},
			"8": {
				"name": "village",
				"icon": "res://Assets/build/village_blue.png",
				"type": "build",
				"weight": 0.01,
				"stackable": true,
				"stack_limit": 10,
				"description": "Scroll: Village for\n 50 inhabitants",
				"sell_price": 2000
				},
		
			"9": {
				"name": "castle",
				"icon": "res://Assets/build/castle_red2.png",
				"type": "build",
				"weight": 0.01,
				"stackable": true,
				"stack_limit": 9999999,
				"description": "Scroll: Old castle for\n 1000 inhabitants",
				"sell_price": 10000
				},
		
			"10": {
				"name": "fortress",
				"icon": "res://Assets/build/fort_pink.png",
				"type": "build",
				"weight": 0.01,
				"stackable": true,
				"stack_limit": 9999999,
				"description": "Scroll: Power fortress \ncastle for 100 inhabitants",
				"sell_price": 10000
				},

			"11": {
				"name": "Capital",
				"icon": "res://Assets/build/capital_pink.png",
				"type": "build",
				"weight": 0.01,
				"stackable": true,
				"stack_limit": 9999999,
				"description": "Scroll:  Capital castle\n for 10000 inhabitants",
				"sell_price": 1000000
				},

			"12": {
				"name": "MagicTown",
				"icon": "res://Assets/build_red/town_red.png",
				"type": "build",
				"weight": 0.01,
				"stackable": true,
				"stack_limit": 9999999,
				"description": "Scroll:  Magic Tower for Mag of Fire ",
				"sell_price": 5000
				},

			"13": {
				"name": "Temple",
				"icon": "res://Assets/build/temple_blue.png",
				"type": "build",
				"weight": 0.01,
				"stackable": true,
				"stack_limit": 1,
				"description": "Scroll: Temple of Your God",
				"sell_price": 15000
				},

			"14": {
				"name": "Barack",
				"icon": "res://Assets/build_pink/barak_pink.png",
				"type": "build",
				"weight": 0.01,
				"stackable": true,
				"stack_limit": 1,
				"description": "Scroll: Barack for Paladin",
				"sell_price": 15000
				},

			"26": {
				"name": "Storage",
				"icon": "res://Assets/build/storage_red.png",
				"type": "build",
				"weight": 0.01,
				"stackable": true,
				"stack_limit": 100,
				"description": "Scroll: Grand Storage",
				"sell_price": 20000,
				},

			"15": {
				"name": "DarkFortress",
				"icon": "res://Assets/build/fortress3.png",
				"type": "build",
				"weight": 0.01,
				"stackable": true,
				"stack_limit": 100,
				"description": "Scroll: Power fortress \n for 100 inhabitants ",
				"sell_price": 50000,
				},

			"16": {
				"name": "village",
				"icon": "res://Assets/build_pink/village_pink2.png",
				"type": "build",
				"weight": 0.01,
				"stackable": true,
				"stack_limit": 9999999,
				"description": "Scroll: Basic settlement\n for 8 inhabitants",
				"sell_price": 2000
				},

			"17": {
				"name": "Settlement",
				"icon": "res://Assets/build/city_build_pink.png",
				"type": "build",
				"weight": 0.01,
				"stackable": true,
				"stack_limit": 1,
				"description": "Scroll: Small new settlement\n for young God",
				"sell_price": 500
				},

			"18": {
				"name": "Peasant",
				"icon": "res://Assets/units2/human/peasant.png",
				"type": "craft",
				"weight": 1,
				"stackable": true,
				"stack_limit": 1,
				"description": "Peasant can work",
				"sell_price": 10,
				"damage": 1,
				"magdamage": 1
				},

			"19": {
				"name": "Alchemist",
				"icon": "res://Assets/units/alchenist_pink.png",
				"type": "craft",
				"weight": 1,
				"stackable": true,
				"stack_limit": 1,
				"description": "Achemist can \ncraft potion ",
				"sell_price": 10,
				"damage": 2,
				"magdamage": 10
				},


			"20": {
				"name": "Ork Warrior",
				"icon": "res://Assets/units/mob/goblin.png",
				"type": "warrior",
				"weight": 1,
				"stackable": true,
				"stack_limit": 1,
				"description": "Strong and power \n Ork-Warrior ",
				"sell_price": 10,
				"damage": 5,
				"magdamage": 1
				},



			"21": {
				"name": "Warlock",
#				"icon": "res://Assets/units/mens/mag.png",
				"icon": "res://Assets/units2/human/mage.png",				
				"type": "mag",
				"weight": 1,
				"stackable": true,
				"stack_limit": 1,
				"description": "Strong and power The Warlock",
				"sell_price": 10,
				"damage": 2,
				"magdamage": 10
				},

			"22": {
				"name": "Priest",
				"icon": "res://Assets/units/mens/priest_green.png",
				"type": "priest",
				"weight": 1,
				"stackable": true,
				"stack_limit": 1,
				"description": "Priest can healing",
				"sell_price": 10,
				"damage": 2,
				"magdamage": 10
				},

			"23": {
				"name": "Priest Exile",
				"icon": "res://Assets/units/mens/priest_pink.png",
				"type": "priest",
				"weight": 1,
				"stackable": true,
				"stack_limit": 1,
				"description": "Priest can get debuff",
				"sell_price": 10,
				"damage": 2,
				"magdamage": 10
				},

			"24": {
				"name": "Crafter",
				"icon": "res://Assets/units/crafter_pink.png",
				"type": "craft",
				"weight": 1,
				"stackable": true,
				"stack_limit": 1,
				"description": "Crafter can \ncraft items ",
				"sell_price": 10,
				"damage": 2,
				"magdamage": 10
				},



			"25": {
				"name": "Vampire High",
				"icon": "res://Assets/units_new/vampire/unit_spy.png",
				"type": "warrior",
				"weight": 1,
				"stackable": true,
				"stack_limit": 1,
				"description": "Fastes High Vampire ",
				"sell_price": 10,
				"damage": 1,
				"magdamage": 1
				},
			
			"51": {
				"name": "Long Sword",
				"icon": "res://Sprites/misc/longsword.png",
				"type": "weapon",
				"damage":12,
				"need_ammo":false,
				"weight": 2,
				"stackable": true,
				"stack_limit": 9999999,
				"description": "Good two-handed sword.\nDamage 5-12",
				"sell_price": 10
			},

			"52": {
				"name": "MagicStuff",
				"icon": "res://Assets/weapon/magic/Stuff.png",
				"type": "weapon",
				"weight": 2,
				"stackable": true,
				"stack_limit": 1,
				"description": "Basic Magic Stuff. \n5-10 Magic damage.\n 2 damage ",
				"sell_price": 10,
				"damage": 2,
				"magdamage": 10
				},
			"53": {
				"name": "Book of Settlement",
				"icon": "res://Assets/Images/shop.png",
				"type": "weapon",
				"weight": 0.5,
				"stackable": true,
				"stack_limit": 9999999,
				"description": "Book for build\nNew Settlement",
				"sell_price": 1000000,
				"damage": 1,
			},


		
			"6": {
				"name": "Horse",
				"icon": "res://Assets/units/vsadnik_red.png",
				"type": "vehicle",
				"max_speed": 60,
				"max_weight": 70,
				"weight": 1,
				"stackable": true,
				"stack_limit": 1,
				"description": "Hovering and faste horse for good travel",
				"sell_price": 250
			},
		},
	},
}


func _ready():
#	if(IS_LOAD_FROM_FILE_ENABLED):
		file = File.new()


func load_data(url:String) -> Dictionary:
	if url == null:
		 return {}
	if(IS_LOAD_FROM_FILE_ENABLED):
		var data = {}
		if !file.file_exists(url):
#			write_data(url, data_global)
			write_data(url, data)			
		else:
			file.open(url, File.READ)
			data_global = parse_json(file.get_as_text())
			file.close()
	return data_global.get(url, {})


func write_data(url, dict:Dictionary):
	if url == null:
		print("url data is null")
		return false
	
	if(IS_LOAD_FROM_FILE_ENABLED):
		var dict_save:Dictionary = {}
		dict_save[url] = dict
		file.open(url, File.WRITE)
		file.store_line(to_json(dict_save))
		file.close()
	else:
		data_global[url] = dict


func delete_file(url:String):
	if data_global.get(url) == null: return
	if(IS_LOAD_FROM_FILE_ENABLED):
		var dir = Directory.new()
		dir.remove(url)
	else:
		data_global.erase(url)
	
func get_kobold():
	return kobold_count #возвращаем  мобов кобольдов	
func get_ork():
	return ork_count #возвращаем  мобов орков	
func get_darkelf():
	return darkelf_count #возвращаем  мобов темных эльфов	
func get_cyclop():
	return cyclop_count #возвращаем  мобов троллей	
func get_magfire():
	return magfire_count #возвращаем  мобов магов огня	
func get_paladin():
	return paladin_count #возвращаем  мобов паладинов	
func get_ghost():
	return ghost_count #возвращаем  мобов призраков
func get_knight():
	return knight_count #возвращаем  мобов  рыцарей
func get_knight_elite():
	return knight_elite_count #возвращаем  мобов элитных рыцарей	
	
func inc_magfire(val):
	magfire_count += val #увеличиваем число мобов магов огня
	add_exp(6)	
func inc_paladin(val):
	paladin_count += val # увеличиваем число мобов паладинов
	add_exp(5)
func inc_darkelf(val):
	darkelf_count += val #увеличиваем число мобов темных эльфов
	add_exp(3)
func inc_cyclop(val):
	cyclop_count += val # увеличиваем число мобов троллей
	add_exp(4)
func inc_kobold(val):
	kobold_count += val #увеличиваем число мобов кобольдов
	add_exp(1)	
func inc_ork(val):
	ork_count += val # увеличиваем число мобов орков
	add_exp(2)  # 2 очка опыта за орка
	
func inc_mobs(race,val):
	if race == 6:
		ghost_count += val # увеличиваем число мобов призраков
		add_exp(5)  # 2 очка опыта за призрака
	if race == 7:
		knight_count += val # увеличиваем число мобов  рыцарей
		add_exp(5)  # 2 очка опыта за  рыцарей
			
	if race == 8:
		peasant_count += val # увеличиваем число мобов элитных рыцарей
		add_exp(2)  # 2 очка опыта за элитных рыцарей
	if race == 9:
		zombie_count += val # увеличиваем число мобов элитных рыцарей
		add_exp(3)  # 2 очка опыта за элитных рыцарей
	if race == 10:
		vampire_count += val # увеличиваем число мобов элитных рыцарей
		add_exp(5)  # 2 очка опыта за элитных рыцарей
	if race == 11:
		vampire_elite_count += val # увеличиваем число мобов элитных рыцарей
		add_exp(10)  # 2 очка опыта за элитных рыцарей
	if race == 12:
		animal_count += val # увеличиваем число мобов элитных рыцарей
		add_exp(6)  # 2 очка опыта за элитных рыцарей
	if race == 13:
		elf_count += val # увеличиваем число мобов элитных рыцарей
		add_exp(6)  # 2 очка опыта за элитных рыцарей
			
func dec_mobs(race,val):
	if race == 6:
		ghost_count -= val # уменьшаем число мобов призраков
		add_exp(5)  # 2 очка опыта за призрака
	if race == 7:
		knight_count -= val # уменьшаем число мобов  рыцарей
		add_exp(5)  # 2 очка опыта за  рыцарей
			
	if race == 8:
		knight_elite_count -= val # уменьшаем число мобов элитных рыцарей
		add_exp(6)  # 2 очка опыта за элитных рыцарей
			
	if race == 9:
		zombie_count -= val # уменьшаем число мобов призраков
		add_exp(5)  # 2 очка опыта за призрака
	if race == 10:
		peasant_count -= val # уменьшаем число мобов  крестьян
		add_exp(5)  # 2 очка опыта за  рыцарей
			
	if race == 11:
		vampire_count -= val # уменьшаем число мобов вампиров
		add_exp(6)  # 2 очка опыта за элитных рыцарей
	if race == 12:
		vampire_elite_count -= val # уменьшаем число мобов высших вампиров
		add_exp(6)  # 2 очка опыта за элитных рыцарей
			
			
	
func dec_kobold(val):
	kobold_count -= val #уменьшаем число мобов кобольдов
	add_exp(1)	
func dec_ork(val):
	ork_count -= val # уменьшаем число мобов орков
	add_exp(2)
func dec_paladin(val):
	paladin_count -= val #уменьшаем число мобов паладинов
	add_exp(5)	
func dec_magfire(val):
	magfire_count -= val # уменьшаем число мобов магов огня
	add_exp(6)
func dec_cyclop(val):
	cyclop_count -= val #уменьшаем число мобов троллей
	add_exp(4)	
func dec_darkelf(val):
	darkelf_count -= val # уменьшаем число мобов темных эльфов
	add_exp(3)

func get_level():
	return level

	
func get_expirience():
	return int(expirience)	
func get_exp_need():
	return int(exp_need)
func get_energy():
	return energy
func get_energy_dark():
	return energy
func get_energy_light():
	return energy




func add_energy(val):
	energy += val
	return energy
		
func add_level(val):
	level += val
#	print("level up")
#	print(level)
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
		set_energy()	#добавляем энергию веры	
		up_exp_need(speed_level)
#		if expirience == 0:
#			return
#		else:
#			add_exp(exp_need)	



func add_expirience(val):
	expirience +=val
	return expirience
		
func up_exp_need(val):
	exp_need *= val
	return int(exp_need)

func set_energy_dark():
	var old_energy = energy
	energy += get_kobold() + get_ork() + get_darkelf() + get_cyclop() + ghost_count + vampire_count + vampire_elite_count + zombie_count
	if energy < 0:
		energy = old_energy	
func set_energy_light():
	var old_energy = energy	
	energy +=get_cyclop() + get_paladin() + get_magfire() + knight_count + knight_elite_count + elf_count + peasant_count	
	if energy < 0:
		energy = old_energy			
func set_energy():
	var old_energy = energy
	if join_race == 0:
		set_energy_light()
	if join_race == 1:
		set_energy_dark()
	if join_race == 2 or join_race == 3:		
		energy += get_count_mobs()
		if get_count_mobs() < 0:
			energy = old_energy
func reduce_energy(val):
#	if join_race == 2 or join_race == 3:
#		return	
	energy -= val
func reduce_energy_vampire(val):
	if join_race == 2 or join_race == 3:
		return	
	energy -= val	
func get_count_mobs():
	var count = kobold_count + ork_count + magfire_count + paladin_count + darkelf_count + cyclop_count + ghost_count + knight_count + knight_elite_count + vampire_count + vampire_elite_count + peasant_count + zombie_count+elf_count
	#get_kobold() + get_ork() + get_darkelf() + get_cyclop() + get_paladin() + get_magfire()
	return count # всего мобов сейчас в мире	
func get_count_builds():
	var count = build_temple + build_farm + build_village + build_castle + build_capital
	return count
