extends Node

# Settings variables
var fullscreen: bool = false
var music_volume: float = 100
var sfx_volume: float = 100
var fov: float = 70.0
var mouse_sensitivity: float = 100
var buttons:Array=[null,null,null,null,null,null,null,null,null,null]
var button_names:Array=["custom up","custom left","custom down","custom right","custom jump","custom esc","custom interact","custom slide","custom reset"]


# Path to the settings file
@onready var settings_file_path: String = "user://settings.cfg"
@onready var default_settings_file_path: String = "user://default_settings.cfg"

func _ready() -> void:
	get_hard_default_inputs()
	load_settings()
	save_settings()
	

var hard_default_inputs:Array
func get_hard_default_inputs():
	hard_default_inputs.resize(button_names.size())
	for i in range(button_names.size()):
		var action_name = button_names[i]
		if InputMap.has_action(action_name):
			print("action found",InputMap.action_get_events(action_name))
			hard_default_inputs[i]=InputMap.action_get_events(action_name)
	print("sucessfully loaded hard default settings")

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
	#var config = ConfigFile.new()
	#var err = config.load(default_settings_file_path)
	#if err == OK:
		#fullscreen = config.get_value("display", "fullscreen", fullscreen)
		#music_volume = config.get_value("audio", "music_volume", music_volume)
		#sfx_volume = config.get_value("audio", "sfx_volume", sfx_volume)
		#fov = config.get_value("gameplay", "fov", fov)
		#mouse_sensitivity = config.get_value("controls", "mouse_sensitivity", mouse_sensitivity)
		#buttons=config.get_value("controls","buttons",buttons)
	#else :print("failed loading default settings err: ",err)
	
	# Default hardcoded values 
	var default_music_volume = 100
	var default_sfx_volume = 100
	var default_fov = 90
	var default_mouse_sensitivity = 50
	music_volume = default_music_volume
	sfx_volume = default_sfx_volume
	fov = default_fov
	mouse_sensitivity = default_mouse_sensitivity

	# Load inputs from InputMap for control not implemented
	for i in range(button_names.size()):
		buttons[i]=hard_default_inputs[i]


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
		pass
		#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	# Apply music and sfx volume settings
	Music.set_Volume(music_volume)
	#AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(sfx_volume))
	
	# Apply mouse sensitivity setting is used in game logic)
	# Apply input maps
	for i in range(button_names.size()):
		
		var action_name = button_names[i]
		if buttons[i] is InputEvent:
			print("valid button")
		else:
			pass
			#break
		InputMap.action_erase_events(action_name)
		# Iterate over each InputEvent in buttons[i]
		if buttons[i] is InputEvent:
			InputMap.action_add_event(action_name, buttons[i])
			print("valid button: Added event:", buttons[i], "to:", action_name)
				
		elif buttons[i] is Array:
			print("not a valid input event trying different aproach")
			for event in buttons[i]:#when a error ocurs here it is probably a null value in the saves
				if event is InputEvent:
					InputMap.action_add_event(action_name, event)
					print("(try2)Added event:", event, "to:", action_name)
				else:
					print("Invalid event type for action:", action_name, "Event:", event)
		else:
			print("button is not a InputEvent getting input from default")
			if InputMap.has_action(action_name):
				print("action found",InputMap.action_get_events(action_name))
				buttons[i]=InputMap.action_get_events(action_name)
				
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
