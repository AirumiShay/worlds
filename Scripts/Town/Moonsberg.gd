extends Area2D


var need_play = false


#func _process(delta):
#	if need_play == false:
#		if	$Wellcome.playing:
#			$Wellcome.stop()
#	if need_play == true:
#		if	$Wellcome.playing == false:				
#			need_play = false
#			$Wellcome.play()
				
func wellcome():
	if need_play == false:
		need_play = true
		$Wellcome.play()
		$Timer.start(3.1)
#		$Wellcome.stream_paused = true		
	else:
		need_play = false
#		$Wellcome.stream_paused = true		
		$Wellcome.stop()
		print(1)
			
func goodbye():
#	$Wellcome.stream_paused = true	
	$Wellcome.stop()
#	need_play = false

func _on_Wellcome_finished():
	
#		$Wellcome.stream_paused = true #stop()
		$Wellcome.stop()
#		need_play = false		


func _on_Timer_timeout():
		$Wellcome.stop()
