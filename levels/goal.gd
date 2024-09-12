extends Node3D

func _on_area_3d_body_entered(_body):
	#loading intermediate screen
	print("goal entered")
	GlobalTime.stop_timer()
	Functions.load_scene("res://GUI/interlevel_screen.tscn")

