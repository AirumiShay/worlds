#extends KinematicBody2D
extends "res://Scripts/Stickman.gd"
# скрипт основного игрока, наследуется от  Player_main.tscn,player.gd


var stands = true
var destination = Vector2()
var velocity = Vector2()
var prev_pos = Vector2()
var x 
var y
var target = null
var default_speed = 65
#var dead = false
#var speed
#var bite_strength = 10
#var target_intercepted = false
#var can_bite = true
var attack = true
var attack_count = 42

#func search_for_target():
#	target = null
#	var pl = get_parent().get_parent().get_player()
##	if pl:
#		if position.distance_to(pl.position) < 200:
#			cancel_movement()
#			speed = default_speed * 3 if speed == default_speed else speed
#			target = pl
#		else:
#			if target:
#				cancel_movement()
#			target = null
#		if target:
#			set_destination(target.position)

func _ready():
	speed = default_speed
#	self.dead = false
	self.hp = 2000
	self.max_hp = 2000
#	print("before start hp")
	set_start_hp(self.hp, self.max_hp)
#	add_to_group(GlobalVars.entity_group)
#	add_to_group(GlobalVars.animal_group)
#	add_to_group(Global_DataParser.players_group)
	add_to_group(Global_DataParser.empire_group)
	Global_DataParser.inc_magfire(1)
#	var skin = ItemMachine.generate_inventory_item("dagger")
#	self.inventory.add_item(skin)
	$DamageNPC.set_damage(42)	
	_prepare_attack()
func _prepare_attack():

		var target_attack = $DamageNPC._attack_true()
		if target_attack["target"] == true:
			cancel_movement()
			set_destination(target_attack["what_target"])
		attack = false
		$TimerAttack.start(2)		
func _process(delta):
#	if self.dead == false:
#		prev_pos = position
	if velocity:
		move_and_slide(velocity)
	#		position.x = clamp(x, 0, 2000)
	#		position.y = clamp(y, 0, 2000)

	wander()
	if attack == true:
		attack_count -= 1
		if 	attack_count < 1:
			Global_DataParser.dec_magfire(1)
			die()
			set_process(false)
			destroy_self()	
			return		
#		print("MagFire ready attack")
		$DamageNPC.set_damage(500)
		_prepare_attack()		
#		$DamageNPC._attack_true()
#		$DamageNPC/Sprite.visible = true
		attack = false
		$TimerHide.start(0.25)		

#		$TimerAttack.start(5)		
#	search_for_target()
	
#		if target_intercepted and can_bite:
#			bite(target)
#	else:
#		cancel_movement()

func set_destination(dest):
	destination = dest
	velocity = (destination - position).normalized() * speed
	stands = false

func cancel_movement():
	velocity = Vector2()
	destination = Vector2()
#	$StandingTimer.start(2)
	speed = default_speed
	
func wander():
	var pos = position
	if stands:
		randomize()
		x = int(rand_range(pos.x - 150, pos.x + 150))
		y = int(rand_range(pos.y - 150, pos.y + 150))
		
#		x = clamp(x, -1500, +1500)
#		y = clamp(y, -1500, +1500)
		
		set_destination(Vector2(x,y))
		
#	elif velocity != Vector2():
#		if pos.distance_to(destination) <= speed:
#			cancel_movement()
#		elif pos.distance_to(destination) <= 0.6:
#			cancel_movement()
			
#func search_for_target():
			
func search_for_target1():
	var pl = get_parent().get_player()
	if position.distance_to(pl.position) < 200:
		cancel_movement()
		speed = default_speed * 3 if speed == default_speed else speed
		target = pl
	else:
		if target:
			cancel_movement()
		target = null
	if target:
		set_destination(target.position)


func _on_Timer_timeout():
	stands = true
#	pass # Replace with function body.


func _on_TimerAttack_timeout():
	attack = true # снова можно атаковать


func _on_TimerHide_timeout():
		$DamageNPC/Sprite.visible = false	
func destroy_self() -> void:
	for child in get_children():
		if child.has_method('queue_free'):
			child.queue_free()
