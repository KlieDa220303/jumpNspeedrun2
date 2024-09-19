extends Control

# Desired aspect ratio (width / height)
@export var target_aspect_ratio: float = 16.0 / 9.0

@export var custom_scale_factor=2
# Reference resolution for scaling
@export var reference_resolution: Vector2 = Vector2(1920, 1080)

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
	#print(self.scale)

	# Center the content
	var new_size:Vector2i = viewport_size * scale_factor
	var offset = (viewport_size - new_size) / 2
	self.position = offset
	

func _on_next_level_button_down():
	Functions.load_level_with_index(Variables.level+1)


func _on_retry_button_down():
	if Variables.level==Variables.number_of_levels and Variables.fullrun_active:#fullrun resetting resets to level 0
		print("reset fullrun")
		Functions.load_level_with_index(0)
	else:
		Functions.load_level_with_index(Variables.level)
	GlobalTime.reset_additional_time()
	Variables.fullrun_active=false


func _on_menu_button_down():
	Functions.load_scene("res://GUI/main_menu.tscn")
	
#text references
@onready var time = $ScrollContainer/PanelContainer/VBoxContainer/HBoxContainer/time
@onready var best_time = $ScrollContainer/PanelContainer/VBoxContainer/HBoxContainer2/best_time
@onready var label_2 = $ScrollContainer/PanelContainer/VBoxContainer/HBoxContainer2/Label2
@onready var next_level = $ScrollContainer/PanelContainer/VBoxContainer/next_level
@onready var label_normal = $ScrollContainer/PanelContainer/VBoxContainer/HBoxContainer/Label
@onready var label_best = $ScrollContainer/PanelContainer/VBoxContainer/HBoxContainer2/Label


# Function to display the times in the formatted way
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	print(GlobalTime._times_array[Variables.level])
	# Display current level time
	var current_time = GlobalTime._times_array[Variables.level]
	time.text = GlobalTime.format_time(current_time)
	
	# Display best time for the current level
	var best_time_value = GlobalTime._best_times_array[Variables.level]
	best_time.text = GlobalTime.format_time(best_time_value)
	
	# Check if the current time is a new best
	if current_time == best_time_value:
		label_2.text = "New Best!"
	else:
		label_2.text = ""
	
	#handling of the next button if level is last
	if Variables.level==Variables.number_of_levels:
		next_level.hide()
	
		print(Variables.fullrun_active,Variables.level,Variables.number_of_levels)
		#overwrite with best level if fullrun active
		if Variables.fullrun_active==true:
			label_normal.text="fullrun time:"
			label_best.text="best fullrun time:"
			time.text = GlobalTime.format_time(GlobalTime._full_run_time)
			
			best_time_value = GlobalTime._best_full_run_time
			best_time.text = GlobalTime.format_time(best_time_value)
		
			# Check if the current time is a new best
			if current_time == best_time_value:
				label_2.text = "New Best!"
			else:
				label_2.text = ""

