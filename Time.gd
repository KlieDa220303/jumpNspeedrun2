extends Node

# Variables to store the start time, elapsed time, and additional time
var start_time: int = 0
var elapsed_time: int = 0
var _additional_time: int = 0  # This tracks additional time when restarting a level

# Arrays to store the times for each level (in milliseconds)
var _times_array: Array = []
var _best_times_array: Array = []

# Full run time and best full run time (in milliseconds)
var _full_run_time: int = -1
var _best_full_run_time: int = -1

# File path for saving/loading the times using ConfigFile
const CONFIG_FILE_PATH = "user://times.cfg"

# Function to initialize the arrays (fill with default values)
func _ready():
	# Load saved times if they exist, otherwise initialize the arrays
	if !load_times():
		_initialize_arrays()
	print("Times Array (on ready):", _times_array)
	print("Best Times Array (on ready):", _best_times_array)
	print("Full Run Time (on ready):", _full_run_time)
	print("Best Full Run Time (on ready):", _best_full_run_time)
	print("Additional Time:", _additional_time)

# Initialize both arrays and full run times with default values (-1 means no time yet)
func _initialize_arrays():
	_times_array.resize(10)
	_best_times_array.resize(10)
	for i in range(10):
		_times_array[i] = -1
		_best_times_array[i] = -1
	_full_run_time = -1
	_best_full_run_time = -1
	_additional_time = 0  # Reset additional time
	print("Initialized arrays and full run times with default values.")

# Function to start the timer
func start_timer():
	if start_time == 0:  # Timer is not started
		start_time = Time.get_ticks_msec()
		print("Timer started for level:", Variables.level)
	else:
		print("Timer is already started.")

# Function to stop the timer and calculate the elapsed time
func stop_timer():
	if start_time == 0:
		print("Timer is not running.")
		return
	
	# Calculate the elapsed time in milliseconds
	elapsed_time = Time.get_ticks_msec() - start_time
	start_time = 0  # Reset start time after stopping the timer
	
	print("Timer stopped at:", elapsed_time, "ms for level:", Variables.level)
	
	# Save the time at the current level index
	save_time(elapsed_time)

# Function to save the time into _times_array and _best_times_array for the current level
func save_time(time: int):
	# Save the time in the _times_array at the index of the current level
	_times_array[Variables.level] = time
	
	# Handle full run logic if active
	if Variables.fullrun_active and Variables.level == Variables.number_of_levels:
		_full_run_time = 0
		# Add all valid level times to calculate the full run time
		for level_time in _times_array:
			if level_time > 0:
				_full_run_time += level_time
		_full_run_time += _additional_time#add aditional times
		
		print("Full Run Time calculated:", _full_run_time, "ms")
		
		# Check if it's the best full run time or if no best full run time is saved yet (-1 means no time)
		if _best_full_run_time == -1 or _full_run_time < _best_full_run_time:
			_best_full_run_time = _full_run_time
			print("New Best Full Run Time:", _best_full_run_time, "ms")

	# Check if it's the best time for the current level or if no best time is saved yet (-1 means no time)
	if _best_times_array[Variables.level] == -1 or time < _best_times_array[Variables.level]:
		_best_times_array[Variables.level] = time  # Save new best time if it's better
	
	# Save the times to the config file
	save_times()
	
	# Print arrays for debugging
	print("Times Array:", _times_array)
	print("Best Times Array:", _best_times_array)
	print("Full Run Time:", _full_run_time)
	print("Best Full Run Time:", _best_full_run_time)

# Function to change the current level
func set_level(new_level: int):
	if new_level >= 0 and new_level < 10:
		Variables.level = new_level
		print("Level set to:", Variables.level)
	else:
		print("Invalid level:", new_level)

# Function to save the arrays and full run times to the config file for persistence
func save_times():
	var config = ConfigFile.new()  # Create a new ConfigFile instance
	
	# Save the times array, best times array, full run time, best full run time, and time to the config file
	config.set_value("Times", "times_array", _times_array)
	config.set_value("Times", "best_times_array", _best_times_array)
	config.set_value("Times", "full_run_time", _full_run_time)
	config.set_value("Times", "best_full_run_time", _best_full_run_time)
	
	# Save the config to the file
	var error = config.save(CONFIG_FILE_PATH)
	if error == OK:
		print("Times saved successfully.")
	else:
		print("Failed to save times, error:", error)

# Function to load the arrays and full run times from the config file
func load_times() -> bool:
	var config = ConfigFile.new()  # Create a new ConfigFile instance
	var error = config.load(CONFIG_FILE_PATH)  # Attempt to load the config file
	
	if error == OK:
		# Load the times_array, best_times_array, full_run_time, and best_full_run_time from the config
		_times_array = config.get_value("Times", "times_array", [])
		_best_times_array = config.get_value("Times", "best_times_array", [])
		_full_run_time = config.get_value("Times", "full_run_time", -1)
		_best_full_run_time = config.get_value("Times", "best_full_run_time", -1)
		
		# If the arrays are empty or invalid, initialize them
		if _times_array.size() == 0 or _best_times_array.size() == 0:
			_initialize_arrays()
			save_times()
			return false
		
		print("Times loaded successfully.")
		return true
	else:
		# If the config file does not exist or failed to load, create a new save file
		print("Save file not found. Creating a new one.")
		_initialize_arrays()  # Initialize arrays with default values
		save_times()  # Save the default values to a new file
		return false

# Function to add the current time to the additional time (used when restarting a level)
func add_additional_time():
	if Variables.fullrun_active==true:
		#add up time
		elapsed_time = Time.get_ticks_msec() - start_time
		start_time = 0  # Reset start time after stopping the timer
		
		_additional_time += elapsed_time
		print("Added", elapsed_time, "ms to additional time. Total additional time:", _additional_time)
		save_times()  # Save the updated additional time

func reset_additional_time():
	print("reset additional time")
	_additional_time=0

# Helper function to format time as minutes:seconds:milliseconds
func format_time(time_in_milliseconds: int) -> String:
	var minutes = int(time_in_milliseconds / 60000)  # 60000 ms in 1 minute
	var seconds = int((time_in_milliseconds % 60000) / 1000)  # 1000 ms in 1 second
	var milliseconds = time_in_milliseconds % 1000  # Remaining milliseconds
	
	# Format the string with leading zeros where necessary
	return str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2) + ":" + str(milliseconds).pad_zeros(3)
