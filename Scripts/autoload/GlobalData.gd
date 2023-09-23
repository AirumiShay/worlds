extends Node

const path		   = "user://data/"
const game_version = 0.100
#Данные для подземелье Астрал
onready var enemy_group = "enemy_group"
#onready var entity_group = "ENTITY"
var main_player_id
var player_level = 1 
var dead_enemy = 0
var player_attack = 1
var dead_player = false
var count_enemy = 0
var count_enemy0 = 0
#Конец данных

var game_status = {
		game_version = 0.100,
		runs = 0
	}

var settings = {
	# Display
		dynamic_cam = false,
		gore        = false,
	
	# Sound
		master_vol = 1,
		music_vol  = 0,
		sfx_vol    = 0
	}


var player_info = {
		nick   = "Vampire",
		kills  = 0,
		deaths = 0,
		posX = 0,
		posY = 0,
		level = 0,
		expirience = 0,
		exp_need = 1,
		energy = 1000,
		energy_dark = 500,
		energy_light = 500
	}

var boolSound = true
var Sound = 1
var boolMusic = true
var Music = 1
var quality = "High" # High, Medium, Low

func _ready():
	loadGameStatus()
	loadSettings()
	loadPlayerInfo()
	_applySettings()


func loadGameStatus():
	var data = Utility.loadDictionary(path + "game_status.json")
	if data:
		Utility.dictionaryCpy(game_status, data)
	else:
		var dir = Directory.new()
		dir.make_dir(path)
		print("GlobalData::Running for the first time!")
	game_status.runs += 1
	Utility.saveDictionary(path + "game_status.json", game_status)
	


func loadSettings():
	if game_status.runs == 1:
		Utility.saveDictionary(path + "settings.json", settings)
		return
	var data = Utility.loadDictionary(path + "settings.json")
	if data:
		Utility.dictionaryCpy(settings, data)


func loadPlayerInfo():
	if game_status.runs == 1:
		Utility.saveDictionary(path + "player_info.json", player_info)
		return
	var data = Utility.loadDictionary(path + "player_info.json")
	if data:
		Utility.dictionaryCpy(player_info, data)



func savePlayerInfo():
	Utility.saveDictionary(path + "player_info.json", player_info)


func saveSettings():
	Utility.saveDictionary(path + "settings.json", settings)


func _applySettings():
	# Apply Sound settings
	Utility.setVolumeLevel(settings.sfx_vol, "weapons")
	Utility.setVolumeLevel(settings.sfx_vol, "messages")
	Utility.setVolumeLevel(settings.music_vol, "bg_sound")
	Utility.setVolumeLevel(settings.master_vol, "Master")
