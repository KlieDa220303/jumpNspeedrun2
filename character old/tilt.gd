extends Node3D
# Tilt parameters
var tilt_angle = 1.5  # The maximum angle the camera will tilt
var tilt_speed = 2.0  # How fast the camera tilts to the maximum angle

# Current tilt direction
var current_tilt = 0.0

#variables for shake
var wait=false

func _ready():
	pass

func _on_character_hit_floor(impactstrenght):
	print("impacted floor with ",impactstrenght)
	if impactstrenght<-5:#minimum threshhold
		if impactstrenght<-40:
			impactstrenght=40
		position.y+=impactstrenght/20
	if impactstrenght<0:
		impactstrenght*=-1
	if impactstrenght>1:
		Sfx.play_jump_sound_effect_with_volume(impactstrenght*5)
	

func _process(delta: float):
	var target_tilt = 0.0
	
	# Check for input and set the target tilt
	if Input.is_action_pressed("ui_left"):
		target_tilt = tilt_angle
	elif Input.is_action_pressed("ui_right"):
		target_tilt = -tilt_angle
	
	# Interpolate current tilt towards the target tilt
	current_tilt = lerp(current_tilt, target_tilt, delta * tilt_speed)
	
	# Apply the tilt to the camera's rotation
	rotation_degrees.z = current_tilt
	#print(rotation.z)
	
	position.y=lerp(position.y,0.0,0.1)
	
	if not on:
		if last_line_instance:
			last_line_instance.hide()
	
	if on:
		on=false

var on=false
func _on_character_draw_line(start_point, end_point, color):
	draw_line(start_point,end_point,Color(0,0,0))
	on=true
	

var last_line_instance: MeshInstance3D = null

# Function to draw a line between two 3D points
func draw_line(start_point: Vector3, end_point: Vector3, color: Color) -> void:
	# If there's a previous line, remove it
	if last_line_instance:
		last_line_instance.queue_free()
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINES)
	st.add_vertex(start_point)
	st.add_vertex(end_point)
	
	var mesh = st.commit()
	
	# Create a new MeshInstance3D for the new line
	last_line_instance = MeshInstance3D.new()
	last_line_instance.mesh = mesh
	add_child(last_line_instance)
	# Ensure it's in global space if the points are global
	last_line_instance.global_transform = Transform3D.IDENTITY
	#last_line_instance.translation = Vector3.ZERO
	
	# Optional: Assign a material to the mesh instance to ensure the color is visible
	var material = StandardMaterial3D.new()
	material.base_color = color
	last_line_instance.material_override = material


