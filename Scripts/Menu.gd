extends Control


const IS_SERVER = false # is this a client or headless server?
var IP_HOST = '127.0.0.1' # localhost

var _player_name = "Anon"
export var room_id: String = ""
export var my_name: String = ""

func _ready():
#	$Main.visible = true
	set_process(false)
	set_process_input(false)
	set_name_player()	
	return
	
func _intro1():
#	$Main.visible = false
	# Enable IME support
	OS.set_ime_active(true)
	$BlockingDialogBox.append_text("Welcom to game: World and Gods",15,56)	
	yield($BlockingDialogBox, "box_hidden")
	$BlockingDialogBox.append_text("HOTKEY: 1 - hit/heal. 2 - Heal. 3 - Repair Builds. 4 - Spell. 5 - Damage . 6 - Farm. 7 - Village. - - Vampire's Fortress", 20,36)
	yield($BlockingDialogBox, "box_hidden")
#	$BlockingInputBox.ask_input()
#	my_name = yield($BlockingInputBox, "text_from_player")
	
#	$Player.set_player_name(my_name)
#	print("Got the name:", my_name)
	$BlockingDialogBox.append_text("8 - VampireCastle. 0 - Call Knight/Undead/DarkElf. 9  - Building Barrack/Home Ork/Home Kobold. = - Building Avanpost/Grymeyard/Outpost ", 20,36)
	yield($BlockingDialogBox, "box_hidden")
#	$BlockingInputBox.ask_input()
	
#	room_id = yield($BlockingInputBox, "text_from_player")
	print("Got the room_id:", room_id)
	$BlockingDialogBox.append_text("P - Controlling mobs(PC only). ENTER - return to God's mode(PC only)", 20, 36)
	yield($BlockingDialogBox, "box_hidden")
	$BlockingDialogBox.append_text("03.09.2023 v 0.101 Created by Airumi and Shaya. Godot Engine. Art & sound from open-source.", 20, 36)
	yield($BlockingDialogBox, "box_hidden")
func _intro():
	return	
func _on_NameLineEdit_text_changed(new_text):
	_player_name = new_text


func _on_CreateButton_pressed():
	var _player_name_length = _player_name.length()
	if(_player_name_length < 1 || _player_name_length > 32):
		$InfoLabel.text ="Nickname should contain from 1 to 32 characters."
		return
	Global_DataParser.DEFAULT_IP   = '10.42.1.1' #IS_LOAD_FROM_FILE_ENABLED = true		
	Global_DataParser._player_name = _player_name
	Global_Network.create_server(_player_name, 3)
	_intro()
	_load_game()


func _on_JoinButton_pressed():
	var _player_name_length = _player_name.length()
	if(_player_name_length < 1 || _player_name_length > 32):
		$InfoLabel.text ="Nickname should contain from 1 to 32 characters."
		return
	Global_DataParser._player_name = _player_name
	Global_Network.connect_to_server(_player_name, 1)
	_intro()
	_load_game()

func _on_ServerButton_pressed():
	_player_name = "Admin"
	Global_DataParser._player_name = "Admin"
	Global_Network.create_server(_player_name, 3)
	_intro()
	_load_game()


func _load_game():
	set_name_player()
	get_tree().change_scene('res://Scenes/Game.tscn')


func _on_IPLineEdit_text_changed(new_text):
	Global_DataParser.DEFAULT_IP = new_text	
	Global_Network.DEFAULT_IP = new_text
#	_player_name = new_text
#	pass # Replace with function body.


func _on_JoinExile_pressed():
	var _player_name_length = _player_name.length()
	if(_player_name_length < 1 || _player_name_length > 32):
		$InfoLabel.text ="Nickname should contain from 1 to 32 characters."
		return
	Global_DataParser._player_name = _player_name
	Global_Network.connect_to_server(_player_name, 2)
	_intro()
	_load_game()


func _on_JoinEmpire_pressed():
	var _player_name_length = _player_name.length()
	if(_player_name_length < 1 || _player_name_length > 32):
		$InfoLabel.text ="Nickname should contain from 1 to 32 characters."
		return
	Global_DataParser._player_name = _player_name		
	Global_Network.connect_to_server(_player_name, 0)
	_intro()
	_load_game()

func set_name_player():
	$Main/NameLineEdit.text = Global_DataParser._player_name


func _on_quit_game_pressed():
	get_tree().quit()
func _on_back_pressed():
	get_tree().quit()


func _on_settings_pressed():

	UImanager.changeMenuTo("settings")


func _on_Help_pressed():
	_intro1()


func _on_Astral_pressed():
	UImanager.changeMenuTo("Astral")
