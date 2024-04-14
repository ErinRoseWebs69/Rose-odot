extends CharacterBody3D

@onready var camera:Camera3D = $Head/Camera3D
@onready var testVis = $Head/Camera3D/TestVisibility

#====MOVEMENT VARIABLES====
var mouse_sens: float = 0.001
var friction: float = 4 #original 4
var accel: float = 12
# 4 for quake 2/3 40 for quake 1/source
# 20 for small-scale
var accel_air: float = 20
# default 15, 8 for small scale
var top_speed_ground: float = 8
# 15 for quake 2/3, 2.5 for quake 1/source
var top_speed_air: float = 2.5
# linearize friction below this speed value
var lin_friction_speed: float = 10
# default 14, 7 for small scale
var jump_force: float = 7
var projected_speed: float = 0
var grounded_prev: bool = true
var grounded: bool = true
var wish_dir: Vector3 = Vector3.ZERO
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#====HEAD BOBBING====
const BOB_FREQ = 1
const BOB_AMP = .2
var t_bob = 0.0

#====Extras====
var interactReach:float = 2.0
var grabReach:float = 2.0
var canInteract:bool
var canGrab:bool
var interactList:Array
var isInteracting:bool

var tempObject

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Head/Camera3D/TestVisibility.target_position = Vector3(0,0,-(interactReach))
	set_collision_layer_value(2, true)

func _input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#elif event.is_action_pressed("ui_cancel"):
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			var adjustMouseVector = (event as InputEventMouseMotion).xformed_by(
				get_tree().root.get_final_transform()).relative
			$Head.rotate_y(-event.relative.x * mouse_sens)
			camera.rotate_x(event.relative.y * mouse_sens)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(60))
	
	if Input.is_action_just_pressed("reload"):
		var root = get_tree().get_first_node_in_group("root")
		#root.clearMap()
		root.genMap()
	if Input.is_action_just_pressed("interact"):
		interactPressed()
	if Input.is_action_just_released("interact"):
		interactReleased()
	if Input.is_action_pressed("interact"):
		interactHold()
	
func _process(delta):
	#if Input.is_action_just_pressed("restart"):
		#restartLevel
	pass

func clip_velocity(normal: Vector3, overbounce: float, delta) -> void:
	var correction_amount: float = 0
	var correction_dir: Vector3 = Vector3.ZERO
	var move_vector: Vector3 = get_velocity().normalized()
	
	correction_amount = move_vector.dot(normal) * overbounce
	
	correction_dir = normal * correction_amount
	velocity -= correction_dir
	# this is only here cause I have the gravity too high by default
	# with a gravity so high, I use this to account for it and allow surfing
	velocity.y -= correction_dir.y * (gravity/20)

func apply_friction(delta):
	var speed_scalar: float = 0
	var friction_curve: float = 0
	var speed_loss: float = 0
	var current_speed: float = 0
	
	# using projected velocity will lead to no friction being applied in certain scenarios
	# like if wish_dir is perpendicular
	# if wish_dir is obtuse from movement it would create negative friction and fling players
	current_speed = velocity.length()
	
	if(current_speed < 0.1):
		velocity.x = 0
		velocity.y = 0
		return
	
	friction_curve = clampf(current_speed, lin_friction_speed, INF)
	speed_loss = friction_curve * friction * delta
	speed_scalar = clampf(current_speed - speed_loss, 0, INF)
	speed_scalar /= clampf(current_speed, 1, INF)
	
	velocity *= speed_scalar

func apply_acceleration(acceleration: float, top_speed: float, delta):
	var speed_remaining: float = 0
	var accel_final: float = 0
	
	speed_remaining = (top_speed * wish_dir.length()) - projected_speed
	
	if speed_remaining <= 0:
		return
	
	accel_final = acceleration * delta * top_speed
	
	clampf(accel_final, 0, speed_remaining)
	
	velocity.x += accel_final * wish_dir.x
	velocity.z += accel_final * wish_dir.z

func air_move(delta):
	apply_acceleration(accel_air, top_speed_air, delta)
	
	# default 14
	clip_velocity(get_wall_normal(), 2, delta)
	clip_velocity(get_floor_normal(), 2, delta)
	
	velocity.y -= gravity * delta

func ground_move(delta):
	floor_snap_length = 0.4
	apply_acceleration(accel, top_speed_ground, delta)
	
	if Input.is_action_pressed("jump"):
		velocity.y = jump_force
	
	if grounded == grounded_prev:
		apply_friction(delta)
	
	if is_on_wall:
		clip_velocity(get_wall_normal(), 1, delta)

func _physics_process(delta):
	grounded_prev = grounded
	# Get the input direction and handle the movement/deceleration.
	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward")
	wish_dir = ($Head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	projected_speed = (velocity * Vector3(1, 0, 1)).dot(wish_dir)
	
#	speed_label.text = str( int( ( velocity * Vector3(1, 0, 1) ).length() ) )
	
	# Add the gravity.
	if not is_on_floor():
		grounded = false
		air_move(delta)
	if is_on_floor():
		if velocity.y > 10:
			grounded = false
			air_move(delta)
		else:
			grounded = true
			ground_move(delta)
	
	t_bob += delta * velocity.length() * float(is_on_floor())
	#camera.transform.origin = _headbob(t_bob)
	
	move_and_slide()
	
	for col_idx in get_slide_collision_count():
		var col := get_slide_collision(col_idx)
		if col.get_collider() is RigidBody3D:
			col.get_collider().apply_central_impulse(-col.get_normal() * 2.0)
			col.get_collider().apply_impulse(-col.get_normal() * 0.01, col.get_position())

#func _headbob(time) -> Vector3:
	#var pos = Vector3.ZERO
	#pos.y = sin(time * BOB_FREQ) * BOB_AMP
	#pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	#
	#var low_pos = BOB_AMP - 0.03
	#
	#return pos

func restartLevel():
	pass


var currentInteractObject
func interactPressed():
	if testVis.is_colliding() and testVis.get_collider().is_in_group("interactable"):
		currentInteractObject = testVis.get_collider()
		if currentInteractObject.has_method("press"):
			currentInteractObject.press("press")

func interactHold():
	if not testVis.is_colliding() and currentInteractObject != null:
		if currentInteractObject.has_method("press"):
			currentInteractObject.press("release")

func interactReleased():
	if testVis.is_colliding() and testVis.get_collider().is_in_group("interactable"):
		currentInteractObject = testVis.get_collider()
		if currentInteractObject.has_method("press"):
			currentInteractObject.press("release")

func interact():
	var object
	
	if isInteracting == true:
		pass
	elif isInteracting == false:
		if testVis.is_colliding() and testVis.get_collider().is_in_group("interactable"):
			object = testVis.get_collider()
			if object.has_method("press"):
				object.press("release")
				object = null
		elif object != null:
			if object.has_method("press"):
				object.press("release")
				object = null
	### TODO: physics object grabbing
