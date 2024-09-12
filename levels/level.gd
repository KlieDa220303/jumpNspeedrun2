extends Node3D

@export var index=0
func _ready(): 
	Variables.level=index
	GlobalTime.start_timer()
	
##screenshot handling
#var frame=0
#func _process(delta):
	#frame+=1
	#print(frame)
	#if frame>3:#count 3 frames
		#Functions.take_screenshot()
		#set_process(false)
