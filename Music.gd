extends Node

#audio
# Declare the music player and the tracks
@export var music_player: AudioStreamPlayer
@export var track_1: AudioStream#menu
@export var track_2: AudioStream#outdoors
@export var track_3: AudioStream#indoors

# Variable to keep track of the current track
var current_track: int = 0

func _ready():
	# Start playing the first track
	change_track(1)

# Function to change the track
func change_track(track_number: int) -> void:
	if track_number!=current_track:
		match track_number:
			1:
				music_player.stream = track_1
			2:
				music_player.stream = track_2
			3:
				music_player.stream = track_3
			_:
				print("Invalid track number:", track_number," switching to track 1")
				music_player.stream = track_1
		
		current_track = track_number
		music_player.play()

# Example: Music.changetrack(1)

# Function to loop the music when it ends
func _on_audio_stream_player_finished():
	music_player.play()

#volume
func set_Volume(loudness: int) -> void:
	# Clamp the loudness value to be between 0 and 100
	loudness = clamp(loudness, 0, 100)
	
	# Convert the loudness value to decibels
	# 0 should map to -80 dB (effectively mute), 100 should map to 0 dB (max volume)
	var volume_db = lerp(-80, 0, loudness / 100.0)
	
	# Set the volume in dB
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), volume_db)
	#music_player.volume_db = volume_db
	print("Volume set to:", loudness, "% (", volume_db, "dB )")
