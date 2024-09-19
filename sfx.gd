extends Node

# Define two AudioStreamPlayer nodes for the sound effects
@onready var sound_effect_1 = $AudioStreamPlayer
@onready var sound_effect_2 = $AudioStreamPlayer2

# Function to play one of the sound effects
func play_jump_sound_effect_with_volume(volume: int):
	# Cap the volume percentage to a maximum of 150%
	volume = min(volume, 150)
	
	# Convert volume percentage to decibels (100% = 0 dB, lower is negative, higher is positive)
	var volume_db = linear_to_db(float(volume) / 100.0)

	# Set the volume (dB) for the sound effect
	sound_effect_1.volume_db = volume_db

	# Stop the sound if it's already playing, then play it again
	if sound_effect_1.is_playing():
		sound_effect_1.stop()
	sound_effect_1.play()

