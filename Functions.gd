extends Node

func load_scene(path):#path in file system or to scene idk
	Settings.load_scene(path)
	
@export var settings_menu_scene=preload("res://GUI/settings_panel.tscn")
func open_settings_menu_as_child_of(node):
	# Freeze the current scene
	print(get_tree().get_first_node_in_group("freeze"))
	Settings.freeze_node(get_tree().get_first_node_in_group("freeze"))#freeze group is for nodes and thier children that will be frozen

	# Instance the settings menu scene
	var settings_menu_instance = settings_menu_scene.instantiate()
	
	# Add the settings menu instance to the current scene
	node.add_child(settings_menu_instance)
	
func load_level_with_index(index):
	match index:
		0:load_scene("res://levels/tutorial_level.tscn")
		1:load_scene("res://levels/level_1.tscn")
		2:load_scene("res://levels/level_2.tscn")
		3:load_scene("res://levels/level_3.tscn")
		4:load_scene("res://levels/level_4.tscn")
		5:load_scene("res://levels/level_5.tscn")
		6:load_scene("res://levels/level_6.tscn")
		7:load_scene("res://levels/level_7.tscn")
		8:load_scene("res://levels/level_8.tscn")
		9:load_scene("res://levels/level_9.tscn")
		_:print("loading level wrong index given or out of range")

func take_screenshot(): # Used for level screenshots
	# Ensure the images folder exists
	var images_folder = "user://level_images/"
	var dir = DirAccess.open(images_folder)

	if dir == null:
		# If the directory doesn't exist, create it with an instance of DirAccess
		dir = DirAccess.make_dir_absolute(images_folder)

	# Get the current viewport texture and extract the image data
	var viewport = get_viewport()
	var img = viewport.get_texture().get_image()

	# Lock the image so it can be read
	#img.lock()

	# Resize the image to 100x100 in place (resize() returns void in Godot 4.x)
	img.resize(100, 100)

	# Unlock the image after resizing
	#img.unlock()

	# Save the image to the images folder in user:// directory
	var screenshot_path = images_folder + "level_" + str(Variables.level) + ".png"
	var error = img.save_png(screenshot_path)

	# Check if the screenshot was saved successfully
	if error == OK:
		print("Screenshot saved successfully to:", screenshot_path)
	else:
		print("Failed to save screenshot with error code:", error)
