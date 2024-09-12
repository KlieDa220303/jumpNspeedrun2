extends Control

# Desired aspect ratio (width / height)
@export var target_aspect_ratio: float = 16.0 / 9.0

#custom scale factor for the right size
@export var custom_scale_factor=1.5
# Reference resolution for scaling
@export var reference_resolution: Vector2 = Vector2(1920, 1080)


func _ready():
	# Connect to the viewport resize signal
	#get_viewport().connect("size_changed", self, "_on_viewport_size_changed")
	# Adjust the scale factor on startup
	_adjust_scale_factor()
	#Functions.load_settings()#reimplement
	load_values()
	#set correct music volume
	Music.set_Volume(Settings.music_volume)


func load_values():
	$ScrollContainer/PanelContainer/HBoxContainer/VBoxContainer/fullscreen/Label2.button_pressed=Settings.fullscreen
	$ScrollContainer/PanelContainer/HBoxContainer/VBoxContainer/music_volume/value.text=var_to_str(Settings.music_volume).pad_decimals(-1)
	$ScrollContainer/PanelContainer/HBoxContainer/VBoxContainer/HScrollBar.value=Settings.music_volume
	$ScrollContainer/PanelContainer/HBoxContainer/VBoxContainer/sfx_volume/value.text=var_to_str(Settings.sfx_volume).pad_decimals(-1)
	$ScrollContainer/PanelContainer/HBoxContainer/VBoxContainer/HScrollBar2.value=Settings.sfx_volume
	$ScrollContainer/PanelContainer/HBoxContainer/VBoxContainer/Fov/value.text=var_to_str(Settings.fov).pad_decimals(-1)
	$ScrollContainer/PanelContainer/HBoxContainer/VBoxContainer/HScrollBar3.value=Settings.fov
	$ScrollContainer/PanelContainer/HBoxContainer/VBoxContainer/sensitivity/value.text=var_to_str(Settings.mouse_sensitivity).pad_decimals(-1)
	$ScrollContainer/PanelContainer/HBoxContainer/VBoxContainer/HScrollBar4.value=Settings.mouse_sensitivity
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
	
	scale_factor*=custom_scale_factor#cusotm solution for this panel
	if scale_factor<1:
		scale_factor=1
	# Apply the scale factor
	self.scale = Vector2(scale_factor, scale_factor)

	# Center the content
	var new_size:Vector2i = viewport_size * scale_factor
	var offset = (viewport_size - new_size) / 2
	self.position = offset


func _on_label_2_toggled(toggled_on):
	Settings.fullscreen=toggled_on
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else :
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	print("fullscreen is ",toggled_on)


func _on_h_scroll_bar_value_changed(value):
	print(var_to_str(value).pad_decimals(-1))
	Settings.music_volume=value
	Music.set_Volume(value)
	$ScrollContainer/PanelContainer/HBoxContainer/VBoxContainer/music_volume/value.text=var_to_str(value).pad_decimals(-1)


func _on_h_scroll_bar_2_value_changed(value):
	print(var_to_str(value).pad_decimals(-1))
	Settings.sfx_volume=value
	$ScrollContainer/PanelContainer/HBoxContainer/VBoxContainer/sfx_volume/value.text=var_to_str(value).pad_decimals(-1)


func _on_h_scroll_bar_3_value_changed(value):
	print(var_to_str(value).pad_decimals(-1))
	Settings.fov=value
	$ScrollContainer/PanelContainer/HBoxContainer/VBoxContainer/Fov/value.text=var_to_str(value).pad_decimals(-1)


func _on_h_scroll_bar_4_value_changed(value):
	print(var_to_str(value).pad_decimals(-1))
	Settings.mouse_sensitivity=value
	$ScrollContainer/PanelContainer/HBoxContainer/VBoxContainer/sensitivity/value.text=var_to_str(value).pad_decimals(-1)


func _on_apply_button_down():
	Settings.save_settings()
	print("saved")


func _on_exit_button_down():
	Settings.close_menu()
	queue_free()
	#if Settings.menu_open==false:
		#Settings.unfreeze_node(get_tree().get_first_node_in_group("main"))
	


func _on_exit_2_button_down():
	Settings.load_defaullt_settings()
	load_values()
	Settings.save_settings()

