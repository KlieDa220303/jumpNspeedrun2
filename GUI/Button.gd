extends Button

@export var action: String
@export var index: int

func _init():
	toggle_mode = true
	theme_type_variation = "RemapButton"


func _ready():
	set_process_unhandled_input(false)
	set_process_input(false)#doesnot work with this for some reason
	update_key_text()


func _toggled(button_pressed):
	set_process_unhandled_input(button_pressed)
	if index==6:
		set_process_input(button_pressed)
		set_process_unhandled_input(false)
	if button_pressed:
		text = "Awaiting Input"
		release_focus()
	else:
		update_key_text()
		grab_focus()


func _unhandled_input(event):
	if event.pressed:
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)
		button_pressed = false

#special fuction incase of mouse input
func _input(event):
	if event is InputEventMouseMotion:
		#print("mouse motion")
		return
	if event is InputEventMouseButton:
		if event.button_index==1:
			print(InputMap.action_get_events(action))
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, event)
			return

	#print(event)
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	button_pressed = false


func update_key_text():
	#print(InputMap.get_actions())
	#print(InputMap.action_get_events(action))
	text = "%s" % InputMap.action_get_events(action)[0].as_text()
	#print(InputMap.action_get_events(action))
	Settings.buttons[index]=InputMap.action_get_events(action)



func _on_reset_button_down():
	update_key_text()
