extends CharacterBody3D

# Constants
const GRAVITY = 9.8
const SPEED = 9.8
# Variables
#variables for slope detection
var is_on_slope = false
var slope_angle = 0.0

# Variables for movement and physics
var current_velocity = Vector3.ZERO
var momentum = Vector3.ZERO
var input_dir
const FRICTION=0.5#friction for moving on the ground

#variables and constants for jumping
const JUMP_SPEED = 6 # Adjust as needed for desired jump height
const JUMP_TIME_ALLOWED = 0.2 # Time in seconds to allow height control
var is_jumping = false
var jump_start_time = 0.0
var jumpexponent=1
var jumpMomentum=momentum

# Additional variables for detecting being stuck
var last_position = Vector3()
var is_stuck = false
var minimum_movement_threshold = 0.01  # Minimum distance expected to move
var time_since_last_check = 0.0

#variables and signal for hitting the floor signal
var impactStrength
var wasInAir=false
signal hitFloor(impactstrenght)

#variables for speedmult
var speedmult=1.1

#variables for time
var time = 0.0

# Variables for mouse input control
var camspeed = 0.01
func _ready():
	camspeed=Settings.mouse_sensitivity/10000
	if camspeed==0:
		camspeed=0.01
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#variable for orb
var color_is_blue=false

#variable for grappling hook
var grappling_allowed=false
var grappling=false
var to_point:Vector3
var original_to_point:Vector3
@onready var shoot_point=$tilt/Camera3D/grab_weapon_position/grappling_shootpoint
signal draw_line(start_point: Vector3, end_point: Vector3, color: Color)

# References to neck and camera nodes for mouse input
@onready var neck := $tilt
@onready var camera := $tilt/Camera3D

#celing detection
@onready var ceiling_ray_cast = $celingCheckRaycast

#wallclimb raycast
@onready var wallclimb_ray_cast = $tilt/wallclimbshapecast
@onready var wallclimb_check_cast = $tilt/wallcheckReycast

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * camspeed)
			camera.rotate_x(-event.relative.y * camspeed)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	#jump indicator
	jump_indicator.text="-"
	
	#settings apply 
	camspeed=Settings.mouse_sensitivity/10000
	camera.fov=Settings.fov
	
	# Get input direction as a Vector3
	var input_vector_2d := Input.get_vector("custom left", "custom right", "custom up", "custom down")
	input_dir = Vector3(input_vector_2d.x, 0, input_vector_2d.y).normalized()

	# Adjust the direction based on neck's orientation
	input_dir = neck.global_transform.basis * input_dir
	
	# Apply gravity if not on floor
	if not is_on_floor():
		wasInAir=true
		current_velocity.y -= GRAVITY * delta
		impactStrength=velocity.y
		#print(impactStrength)
		if input_dir.length() > 0 and not grappling:#movement on floor and sliding
				momentum += input_dir * SPEED * 1.2 * delta
		else: momentum=momentum/1.01
		
		
	# Manually clamp the momentum in some cenarios
	if momentum.length() > SPEED and not grappling_allowed and not is_on_floor() and not grappling:
		momentum = momentum.normalized() * SPEED
	#print(momentum)
	# Handle momentum and movement based on whether the character is on the floor
	if is_on_floor():
		if wasInAir==true:
			emit_signal("hitFloor",impactStrength)
			#print("emitted signal hit floor,", impactStrength)
			wasInAir=false
			impactStrength=0
		if input_dir.length() > 0 and  momentum.length() < SPEED:
				momentum += input_dir * SPEED * 6 * delta
		else: momentum=momentum/1.15
		current_velocity.y=0
		jumpexponent=1
		#jump
		if Input.is_action_just_pressed("custom jump")and is_jumping==false:
			#current_velocity.y=0
			is_jumping = true
			jumpMomentum=momentum
			jump_start_time = Time.get_ticks_msec() / 1000.0
		if not is_jumping:
			jump_indicator.text="#"

	#handle jump
	if is_jumping and Input.is_action_pressed("custom jump"):
		if Time.get_ticks_msec() / 1000.0 - jump_start_time < JUMP_TIME_ALLOWED:
			#print("jumping")
			current_velocity.y=JUMP_SPEED*jumpexponent
			jumpexponent+=0.02
		else:
			is_jumping = false # Stop the jump if time limit exceeded
	else : is_jumping = false # Stop the jump if button released
	
	if is_on_ceiling():
		is_jumping=false # stop the jump if on celing
		current_velocity.y=-1
	
	# Update the timer and check if it's time to see if we're stuck
	time_since_last_check += delta
	if is_on_slope:
		check_if_stuck()
		time_since_last_check = 0.0
	#what to do if stuck
	if is_stuck:
		current_velocity.y+=deg_to_rad(slope_angle)
	
	# input handling for sliding
	if Input.is_action_just_pressed("custom slide"):
		slide()
	elif not Input.is_action_pressed("custom slide") and not is_wall_above():
		stand_up()
	#hanle sliding
	if is_sliding and is_on_floor():
		if speedmult>0.5:
			speedmult/=1.01
		#print (speedmult)
	elif input_dir.length() > 0:
		speedmult=1
		#emit_signal("moving")
		
	#wallclimb handling
	#if wallclimb_ray_cast.is_colliding():print("is colliding")
	#else :print("not colldiding")
	if not wallclimb_ray_cast.is_colliding() and wallclimb_check_cast.is_colliding() and is_on_wall():
		jump_indicator.text="#"
	if Input.is_action_just_pressed("custom jump") and not wallclimb_ray_cast.is_colliding() and wallclimb_check_cast.is_colliding() and is_on_wall():
		print("jump")
		is_jumping = true
		jumpMomentum=momentum/2
		jump_start_time = Time.get_ticks_msec() / 1000.0
	
	
	if Input.is_action_just_pressed("custom interact") and grappling_allowed and not grappling:
		start_grapple()
		grappling=true
	if grappling_allowed:
		show_grapple_poin()
	if Input.is_action_pressed("custom interact") and grappling:
		var from_point=shoot_point.global_position
		to_point=original_to_point
		emit_signal("draw_line",from_point,to_point,Color(0,0,0))
		draw_sphere(to_point)
		if to_point.y-position.y>1:
			print("distance to low")
			current_velocity.y+=(to_point.y-position.y)/30
			if input_dir.length() > 0:
				momentum += input_dir*SPEED*delta
		if to_point.y-position.y<-15:
			print("distance to high")
			current_velocity.y+=(to_point.y-position.y)/30/2
			if input_dir.length() > 0:
				momentum += input_dir*SPEED*delta
		momentum += get_direction(position,to_point) * SPEED * (position.distance_to(to_point)/6) * delta
		print(to_point.y-position.y)
		
		#draw rope
		#move
	if Input.is_action_just_released("custom interact") and grappling:
		grappling=false
	
	current_velocity.x = momentum.x
	current_velocity.z = momentum.z
	velocity=current_velocity*speedmult
	# Movement execution
	move_and_slide()

	# Slope detection
	if is_on_floor():
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			if collision != null:
				var floor_normal = collision.get_normal()
				if floor_normal != Vector3.UP:  # This indicates a slope
					is_on_slope = true
				slope_angle = rad_to_deg(acos(floor_normal.dot(Vector3.UP)))
				#print("On slope with angle: ", slope_angle)
				break  # Assuming only one floor collision is relevant per frame
			else: slope_angle=0

	 #control for picking up and releasing objects
	if Input.is_action_pressed("custom interact") and not grappling_allowed:
		try_pick_up()
	else: release_object()
	
	#reset
	if position.y<-50 or Input.is_action_just_pressed("custom reset"):
		GlobalTime.add_additional_time()
		reload_current_scene()
@onready var jump_indicator = $"hud/VBoxContainer/jump indicator"


var original_from_point:Vector3
func start_grapple():
	#print("character global is: ",global_position)
	var raycast=$tilt/Camera3D/grappling_raycast
	original_to_point=raycast.get_collision_point()
	original_from_point=position
	##todo
	#get distance to hit point and draw line from grappling point to hit point
	#the physics


func get_direction(start_pos: Vector3, end_pos: Vector3) -> Vector3:
	var direction = end_pos - start_pos
	return direction.normalized()


func show_grapple_poin():
	draw_sphere($tilt/Camera3D/grappling_raycast.get_collision_point())

# Keep a reference to the last drawn sphere
var last_sphere_instance: MeshInstance3D = null

# Function to draw a sphere at a specified 3D position
func draw_sphere(position: Vector3, radius: float = 0.5, color: Color = Color.WHITE) -> void:
	# If there's a previous sphere, remove it
	if last_sphere_instance:
		last_sphere_instance.queue_free()
	
	# Create the SphereMesh
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = radius
	sphere_mesh.height = radius * 2
	sphere_mesh.radial_segments = 32
	sphere_mesh.rings = 16
	color=Color(1, 0, 0, 0.5)

	# Create a MeshInstance3D node to display the sphere
	last_sphere_instance = MeshInstance3D.new()
	last_sphere_instance.mesh = sphere_mesh
	add_child(last_sphere_instance)
	last_sphere_instance.global_transform.origin = position
	
	# Create and assign a material to color the sphere
	var material = StandardMaterial3D.new()
	material.TRANSPARENCY_ALPHA
	material.albedo_color=Color(1, 0, 0, 0.5)
	last_sphere_instance.material_override = material
	
func _on_area_3d_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	print(area)
	print(area.get_meta_list())
	if area.has_meta("grappling_hook"):
		grappling_allowed=true
		$tilt/Camera3D/grab_weapon_position.show()
		print("grappling on")


func is_wall_above() -> bool:
	# Check if the raycast has detected an object.
	if ceiling_ray_cast.is_colliding():
		return true  # There is something above the player.
	else:
		return false  # There is nothing above the player.

func check_if_stuck():
	var current_position = global_transform.origin
	var distance_moved = current_position.distance_to(last_position)
	
	# Assuming 'is_on_slope()' is a method that determines if the player is currently on a slope
	if is_on_slope and distance_moved < minimum_movement_threshold and slope_angle<50 and input_dir.length() > 0:
		#print("Player is stuck on a slope.")
		is_stuck = true
	else:
		#print("Player is not stuck.")
		is_stuck = false
		
	last_position = global_transform.origin  # Update last position for the next check
	
#slide variables
# Reference to the collision shape and camera
@onready var collision_shape = $CollisionShape3D
@onready var slide_ollision_shape = $slideCollisionShape
#camera is already declared

# Original and slide positions for the camera
var original_camera_position = Vector3(0, 0.6, 0)  # Example position, adjust as needed
var slide_camera_position = Vector3(0, -0.2, 0)  # Lower camera position during slide

# State control
var is_sliding = false
var is_slide_allowed=true
# time for slide
const SLIDEDURATION=35
var slide_duration = SLIDEDURATION  # Duration of the slide in miliseconds
var slide_timer = 0.0  # Tracks the elapsed time of the slide


func slide():
	if is_sliding:
		return  # Avoid re-triggering slide if already sliding

	slide_timer=time
	is_sliding = true
	#print("initial time:", slide_timer)
	# Adjust the collision shape for sliding
	if collision_shape and collision_shape.shape:
		collision_shape.disabled=true
		slide_ollision_shape.disabled=false
		

	# Move the camera down smoothly
	# This is a simple direct adjustment, consider using lerp or Tween for smoother transitions
	camera.position = slide_camera_position
	

func stand_up():
	# Reset sliding state
	is_sliding = false
	# Reset the collision shape
	collision_shape.disabled=false
	slide_ollision_shape.disabled=true

	# Move the camera back to its original position smoothly
	camera.position = original_camera_position
#grabbing rigidbodys
@onready var grabbing=$tilt/Camera3D/grabbRaycast
@onready var grabbpoint=$tilt/Camera3D/grabbPoint
var held_object: RigidBody3D = null
var body
var is_picking_up=false

#pickuptimer variables
var endtime=0
var duration=200
var timeractive=false

var is_pickup_allowed=true

func detect_rigidbody_in_front() -> RigidBody3D:
	# Implement detection logic here, returning a RigidBody3D if one is detected
	if grabbing.is_colliding() and grabbing.get_collider().has_meta("grabbable"):
		if grabbing.get_collider().get_meta("grabbable"):
			return grabbing.get_collider()
		else: return null
	else :return null

func try_pick_up():
	body = detect_rigidbody_in_front() 
	if body:
		if body.get_contact_count()==0:
			body.global_position=grabbpoint.global_position
		else : 
			body.global_position.x=move_toward(body.global_position.x,grabbpoint.global_position.x,0.01)
			body.global_position.y=move_toward(body.global_position.y,grabbpoint.global_position.y,0.01)
			body.global_position.z=move_toward(body.global_position.z,grabbpoint.global_position.z,0.01)
		body.linear_velocity=current_velocity/1.5
		#body.linear_velocity=Vector3.ZERO
		#print(body.linear_velocity)

func release_object():
	
	held_object = null

signal reloading_soon()
func reload_current_scene():
	emit_signal("reloading_soon")
	var current_scene = get_tree().current_scene
	if current_scene:
		var result = get_tree().reload_current_scene()
		if result != OK:
			push_error("Failed to reload the current scene.")

signal hit_goal_signalbooster()
func _on_goal_hit_goal():
	emit_signal("hit_goal_signalbooster")
	

##next to implement:
##speedmult increasing
