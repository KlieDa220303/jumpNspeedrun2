extends Control

# Desired aspect ratio (width / height)
@export var target_aspect_ratio: float = 16.0 / 9.0

@export var custom_scale_factor=2
# Reference resolution for scaling
@export var reference_resolution: Vector2 = Vector2(1920, 1080)

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Variables.fullrun_active=false
	GlobalTime.reset_additional_time()

func _on_resized():
	_adjust_scale_factor()

func _adjust_scale_factor():
	var viewport_size = get_viewport().size
	var viewport_aspect_ratio = viewport_size.x / viewport_size.y
	
	var scale_factor: float
	
	# Determine the scale factor based on the aspect ratio
	if viewport_aspect_ratio > target_aspect_ratio:
		scale_factor = viewport_size.y / reference_resolution.y
	else:
		scale_factor = viewport_size.x / reference_resolution.x
	
	scale_factor*=custom_scale_factor#custom solution for this panel
	if scale_factor<1:
		scale_factor=1
	# Apply the scale factor
	self.scale = Vector2(scale_factor, scale_factor)
	print(self.scale)

	# Center the content
	var new_size:Vector2i = viewport_size * scale_factor
	var offset = (viewport_size - new_size) / 2
	self.position = offset
	


func _on_button_button_down():
	Functions.load_scene("res://GUI/main_menu.tscn")


func _on_label_2_meta_clicked(meta):
	OS.shell_open("https://www.youtube.com/@dustyfurniture514")
