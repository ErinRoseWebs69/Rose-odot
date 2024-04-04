extends CharacterBody3D

@onready var camera:Camera3D = $Head/Camera3D
@onready var gunSprite:AnimatedSprite2D = $Head/CanvasLayer/gunBase/AnimatedSprite2D

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



#====GUNGAME VARIABLES====
@onready var anim_sprite = $Head/CanvasLayer/gunBase/AnimatedSprite2D
@onready var raycast = $Head/Camera3D/RayCast3D
@onready var meleeRaycast = $Head/Camera3D/RayCast3D2
@onready var SFXPLAYER = null
var canShoot:bool = true
var isDead:bool = false
var currentGun:String
var gunInv:Dictionary = {
	"none": "none",
	"wrench": "locked",
	"pistol": "locked",
	"shotgun": "locked",
	"repeater": "locked",
	"bow": "locked",
	"grenade": "locked"
}
var health = 100

var wrenchDamage = 5
var pistolDamage = 3
var shotgunDamage = 7
var repeaterDamage = 3
var bowDamage = 20
var grenadeDamage = 20

var wrenchCooldown:float = 2.0
var pistolCooldown:float = 2.0
var shotgunCooldown:float = 3.0
var repeaterCooldown:float = 0.25
var bowCooldown:float = 5.0
var grenadeCooldown:float = 6.0
var pistolReloadTime:float = 5.0
var shotgunReloadTime:float = 7.0
var repaterReloadTime:float = 10.0
var bowReloadTime:float = 5.0
var grenadeReloadTime:float = 6.0
#ammo size
var pistolAmmo:int
var shotgunAmmo:int
var repeaterAmmo:int
var bowAmmo:int
var grenadeAmmo:int
var pistolMagSize:int = 12
var shotgunMagSize:int = 6
var repeaterMagSize:int = 36
var bowMagSize:int = 1
var grenadeMagSize:int = 1
var pistolMaxAmmo:int = 120
var shotgunMaxAmmo:int = 100
var repeaterMaxAmmo:int = 360
var bowMaxAmmo:int = 20
var grenadeMaxAmmo:int = 21
var pistolMaxAmmoCount:int
var shotgunMaxAmmoCount:int
var repeaterMaxAmmoCount:int
var bowMaxAmmoCount:int
var grenadeMaxAmmoCount:int

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	anim_sprite.animation_finished.connect(shootAnimDone)
	currentGun = "none"
	#replace later
	pistolMaxAmmoCount = pistolAmmo + pistolMaxAmmo

func _input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#elif event.is_action_pressed("ui_cancel"):
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			var adjustMouseVector = (event as InputEventMouseMotion).xformed_by(
				get_tree().root.get_final_transform()).relative
			self.rotate_y(-event.relative.x * mouse_sens)
			camera.rotate_x(-event.relative.y * mouse_sens)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(60))
	
	if Input.is_action_just_pressed("reload"):
		var root = get_tree().get_first_node_in_group("root")
		#root.clearMap()
		root.genMap()
	
	if isDead:
		return
	if Input.is_action_just_pressed("primaryFire"):
		shoot(0)
	if Input.is_action_just_pressed("altFire"):
		shoot(1)
	if Input.is_action_just_pressed("gun1"):
		switchWeapons(1)
	if Input.is_action_just_pressed("gun2"):
		switchWeapons(2)
	if Input.is_action_just_pressed("gun3"):
		switchWeapons(3)
	if Input.is_action_just_pressed("gun4"):
		switchWeapons(4)
	if Input.is_action_just_pressed("gun5"):
		switchWeapons(5)
	if Input.is_action_just_pressed("gun6"):
		switchWeapons(6)
	#if Input.is_action_just_pressed("reload"):
		#match currentGun:
			#"wrench":
				#pass
			#"pistol":
				#if pistolMaxAmmoCount > pistolMagSize:
					#pistolAmmo = pistolMagSize
				#else:
					#pistolAmmo = pistolMaxAmmoCount
			#"shotgun":
				#if shotgunMaxAmmoCount > shotgunMagSize:
					#shotgunAmmo = shotgunMagSize
				#else:
					#shotgunAmmo = shotgunMaxAmmoCount
			#"repeater":
				#if repeaterAmmo > repeaterMagSize:
					#repeaterAmmo = repeaterMagSize
				#else:
					#repeaterAmmo = repeaterMaxAmmoCount
			#"bow":
				#if bowAmmo > bowMagSize:
					#bowAmmo = bowMagSize
				#else:
					#bowAmmo = repeaterMaxAmmoCount
			#"grenade":
				#if grenadeAmmo > grenadeMagSize:
					#grenadeAmmo = grenadeMagSize
				#else:
					#grenadeAmmo = grenadeMaxAmmoCount

func _process(delta):
	#if Input.is_action_just_pressed("restart"):
		#restartLevel()
	
	if isDead:
		return

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
	if isDead:
		return
	grounded_prev = grounded
	# Get the input direction and handle the movement/deceleration.
	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward")
	wish_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
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
	camera.transform.origin = _headbob(t_bob)
	gunSprite.transform.origin = _gunbob(t_bob)
	
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	
	var low_pos = BOB_AMP - 0.03
	
	return pos

func _gunbob(time) -> Vector2:
	var pos = Vector2.ZERO
	pos.y = sin(time * BOB_FREQ) * (BOB_AMP * 80)
	pos.x = cos(time * BOB_FREQ / 2) * (BOB_AMP * 80)
	
	var low_pos = BOB_AMP - 1.0
	
	return pos

func restartLevel():
	pass

func takeDamage(damage):
	health -= damage
	$Head/CanvasLayer/BoxContainer/Label.text = "health: " + str(health)
	print(health)
	if health <= 0:
		print("ded")

func shoot(attackType:int):
	if not canShoot:
		return
	canShoot = false
	anim_sprite.play("fire")
	#firing SFX manager
	if currentGun == "wrench":
		print("melee attack")
		if meleeRaycast.is_colliding() and meleeRaycast.get_collider().has_method("takeDamage"):
			meleeRaycast.get_collider().takeDamage(5)
	elif currentGun == "grenade":
		# TODO: actually make grenade functionality lol
		print("grenade things done")
		reload("grenade")
	elif currentGun == "none":
		print("no weapon selected")
	else:
		print("gun shot")
		var damage
		if raycast.is_colliding() and raycast.get_collider().has_method("takeDamage"):
			#raycast.get_collider().takeDamage(3)
			#change depending on weapon
			match currentGun:
				"pistol":
					damage = 3
					if pistolAmmo <= 0:
						reload("pistol")
				"shotgun":
					damage = 7
					if shotgunAmmo <= 0:
						reload("shotgun")
				"repeater":
					damage = 2
					if repeaterAmmo <= 0:
						reload("repeater")
				"bow":
					damage = 20
					if bowAmmo <= 0:
						reload("bow")
			raycast.get_collider().takeDamage(damage)

func shootAnimDone():
	canShoot = true

func switchWeapons(gunIndex):
	match gunIndex:
		1:
			print(str(gunInv.get("wrench")))
			if gunInv.get("wrench") == "unlocked":
				print("switched to fanblade")
				currentGun = "wrench"
				print("current weapon: " + currentGun)
			else:
				print("fanblade locked")
		2:
			print(str(gunInv.get("pistol")))
			if gunInv.get("pistol") == "unlocked":
				print("switched to pistol")
				currentGun = "pistol"
				print("current weapon: " + currentGun)
			else:
				print("pistol locked")
		3:
			print(str(gunInv.get("shotgun")))
			if gunInv.get("shotgun") == "unlocked":
				print("switched to shotgun")
				currentGun = "shotgun"
				print("current weapon: " + currentGun)
			else:
				print("shotgun locked")
		4:
			print(str(gunInv.get("repeater")))
			if gunInv.get("repeater") == "unlocked":
				print("switched to repeater")
				currentGun = "repeater"
				print("current weapon: " + currentGun)
			else:
				print("repeater locked")
		5:
			print(str(gunInv.get("bow")))
			if gunInv.get("bow") == "unlocked":
				print("switched to bow")
				currentGun = "bow"
				print("current weapon: " + currentGun)
			else:
				print("bow locked")
		6:
			print(str(gunInv.get("grenade")))
			if gunInv.get("grenade") == "unlocked":
				print("switched to grenade")
				currentGun = "grenade"
				print("current weapon: " + currentGun)
			else:
				print("grenade locked")
	$Head/CanvasLayer/BoxContainer/Label2.text = "weapon: " + currentGun

func reload(gun):
	pass

func unlockGun(gun):
	match gun:
		"wrench":
			gunInv["wrench"] = "unlocked"
		"pistol":
			gunInv["pistol"] = "unlocked"
		"shotgun":
			gunInv["shotgun"] = "unlocked"
		"repeater":
			gunInv["repeater"] = "unlocked"
		"bow":
			gunInv["bow"] = "unlocked"
		"grenade":
			gunInv["grenade"] = "unlocked"
