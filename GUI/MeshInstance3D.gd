extends MeshInstance3D

func _ready():
	rotation.y=Variables.menu_rotation

func _process(delta):
	rotation.y-=0.001
	Variables.menu_rotation=rotation.y
