extends Control

# Desired aspect ratio (width / height)
@export var target_aspect_ratio: float = 16.0 / 9.0

@export var custom_scale_factor=1.2
# Reference resolution for scaling
@export var reference_resolution: Vector2 = Vector2(1920, 1080)
#fullrun level reference
@onready var fullrun_label = $ScrollContainer/PanelContainer/GridContainer/fullrun_label


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	generate_level_buttons()
	#fullrun label time
	fullrun_label.text=str("best fullrun time: 
		",GlobalTime.format_time(GlobalTime._best_full_run_time))

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
	
# Number of levels
var number_of_levels: int = Variables.number_of_levels

# Path to the images folder (images should be named like "level_1.png", "level_2.png", etc.)
@export var images_folder: String = "res://textures/level_images/"

#default image load path
const DEFAULT = preload("res://textures/default.png")

# GridContainer to hold the buttons (you can also use VBoxContainer or HBoxContainer depending on your layout)
@onready var grid_container = $ScrollContainer/PanelContainer/GridContainer

# Function to generate a `TextureButton` with corresponding image and text for each level
func generate_level_buttons():
	for i in number_of_levels+1:#+1 because we start with 0
		var level_index = i  # Level numbers start from 0

		# Create a new TextureButton for each level
		var texture_button = TextureButton.new()

		
		# Load the image for the button's normal state
		var texture_path = images_folder + "level_" + str(level_index) + ".png"
		var texture = load(texture_path)

		if texture!=null:
			# Assign the texture to the normal state of the TextureButton
			texture_button.texture_normal = texture
		else:
			texture_button.texture_normal=DEFAULT
		# Create a Label to display the level number and add it as a child of the button
		var label = Label.new()
		#label.text = "Level " + str(level_index)
		label.text="time:" +str(GlobalTime.format_time(GlobalTime._best_times_array[level_index]))
		#label.align = Label.ALIGN_CENTER
		#label.valign = Label.VALIGN_CENTER
		label.autowrap_mode=TextServer.AUTOWRAP_OFF

		# Add the label as a child of the texture button
		texture_button.add_child(label)

		# Use `Callable` and `bind()` for connecting signals in Godot 4.x
		texture_button.connect("pressed", Callable(self, "_on_level_button_pressed").bind(level_index))

		# Add the button to the GridContainer (or any container you're using)
		grid_container.add_child(texture_button)
		
# Function called when a level button is pressed
func _on_level_button_pressed(level_number: int):
	print("Level ", level_number, " selected")
	Functions.load_level_with_index(level_number)
	# Add level loading logic here#done

func _input(event):
	if Input.is_action_just_pressed("custom esc"):
		_on_button_button_down()

func _on_button_button_down():
	Functions.load_scene("res://GUI/main_menu.tscn")
