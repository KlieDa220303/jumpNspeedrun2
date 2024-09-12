extends Node3D

func _process(delta):
	rotate_y(0.05)


func _on_area_3d_body_entered(body):
	hide()
	print("hidden")
