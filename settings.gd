extends Node

# Settings variables
var fullscreen: bool = false
var music_volume: float = 100
var sfx_volume: float = 100
var fov: float = 70.0
var mouse_sensitivity: float = 100
var buttons:Array=[InputEventKey.new(),null,null,null,null,null,null,null,null,null]
var button_names:Array=["custom up","custom left","custom down","custom right","custom jump","custom esc","custom interact","custom slide","custom reset"]


# Path to the settings file
@onready var settings_file_path: String = "user://settings.cfg"
@onready var default_settings_file_path: String = "res://default_settings.cfg"

func _ready() -> void:
	load_settings()
	save_settings()

func load_settings() -> void:
	var config = ConfigFile.new()
	var err = config.load(settings_file_path)
	if err == OK:
		fullscreen = config.get_value("display", "fullscreen", fullscreen)
		music_volume = config.get_value("audio", "music_volume", music_volume)
		sfx_volume = config.get_value("audio", "sfx_volume", sfx_volume)
		fov = config.get_value("gameplay", "fov", fov)
		mouse_sensitivity = config.get_value("controls", "mouse_sensitivity", mouse_sensitivity)
		buttons=config.get_value("controls","buttons",buttons)
		print("settings loaded sucessfully")
	else:
		load_defaullt_settings()

func load_defaullt_settings() -> void:
	var config = ConfigFile.new()
	var err = config.load(default_settings_file_path)
	if err == OK:
		fullscreen = config.get_value("display", "fullscreen", fullscreen)
		music_volume = config.get_value("audio", "music_volume", music_volume)
		sfx_volume = config.get_value("audio", "sfx_volume", sfx_volume)
		fov = config.get_value("gameplay", "fov", fov)
		mouse_sensitivity = config.get_value("controls", "mouse_sensitivity", mouse_sensitivity)
		buttons=config.get_value("controls","buttons",buttons)

func save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("display", "fullscreen", fullscreen)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("gameplay", "fov", fov)
	config.set_value("controls", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("controls","buttons",buttons)
	config.save(settings_file_path)
	load_settings()
	apply_settings()
	print("settings saved sucessfully")

func apply_settings():
	# Apply fullscreen setting
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else :
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	# Apply music and sfx volume settings
	Music.set_Volume(music_volume)
	#AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(sfx_volume))
	
	# Apply mouse sensitivity setting is used in game logic)
	# Apply input maps
	for i in range(button_names.size()):
		var action_name = button_names[i]
		InputMap.action_erase_events(action_name)
		
		# Iterate over each InputEvent in buttons[i]
		if buttons[i] is InputEvent:
			InputMap.action_add_event(action_name, buttons[i])
			print("Added event:", buttons[i], "to:", action_name)
				
		else :
			for event in buttons[i]:#when a error ocurs here it is probably a null value in the saves
				if event is InputEvent:
					InputMap.action_add_event(action_name, event)
					print("Added event:", event, "to:", action_name)
				else:
					print("Invalid event type for action:", action_name, "Event:", event)

#freeze and show settings menu
@export var settings_menu_scene=preload("res://GUI/settings_panel.tscn")
func open_settings_menu():
	# Freeze the current scene
	#get_tree().paused = true
	print(get_tree().get_first_node_in_group("freeze")," to be frozen")
	freeze_node(get_tree().get_first_node_in_group("freeze"))

	# Instance the settings menu scene
	var settings_menu_instance = settings_menu_scene.instantiate()
	
	# Add the settings menu instance to the current scene
	add_child(settings_menu_instance)
	menu_open=true
# Function to recursively freeze a node and its subnodes
func freeze_node(node: Node):
	if node:
		node.process_mode=Node.PROCESS_MODE_DISABLED
		for child in node.get_children():
			if child is Node:
				freeze_node(child)

# Function to recursively unfreeze a node and its subnodes
func unfreeze_node(node: Node):
	if node:
		node.process_mode=Node.PROCESS_MODE_INHERIT
		for child in node.get_children():
			if child is Node:
				unfreeze_node(child)

#scene loading
var loading_screen_scene =preload("res://GUI/loading_scene.tscn") 
var scene_to_load

func load_scene(path) -> void:
	scene_to_load=path
	freeze_node(get_tree().get_first_node_in_group("freeze"))
	var loading_screen = loading_screen_scene.instantiate()
	
	add_child(loading_screen)
	#get_tree().change_scene_to_file(loading_scene_path)

var esc_menu_scene=preload("res://GUI/esc_menu.tscn")
var menu_open=false
func  open_esc_menu():
	freeze_node(get_tree().get_first_node_in_group("freeze"))
	var esc_menu = esc_menu_scene.instantiate()
	add_child(esc_menu)
	menu_open=true

func close_menu():
	unfreeze_node(get_tree().get_first_node_in_group("freeze"))
	menu_open=false
