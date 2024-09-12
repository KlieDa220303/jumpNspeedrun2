extends Control

var start_time = 0
var running = false
var time_passed=0

func _ready():
	set_process(true)
	start_time = 0
	start_timer()


func _process(_delta):
	if running:
		time_passed = Time.get_ticks_msec() - start_time
		
		var milliseconds = time_passed % 1000
		var seconds_total = time_passed / 1000
		var seconds = seconds_total % 60
		var minutes = (seconds_total / 60) % 60
		
		$VBoxContainer/timer.text = "%02d:%02d.%03d" % [minutes, seconds, milliseconds]
	
	if Input.is_action_just_pressed("custom esc"):
		Settings.open_esc_menu()

func start_timer():
	start_time = Time.get_ticks_msec()
	running = true
