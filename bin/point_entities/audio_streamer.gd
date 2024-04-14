extends AudioStreamPlayer3D

class_name audio_streamer

func _init(entityData, world):
	name = entityData["name"]
	stream = ResourceLoader.load("res://sounds/" + entityData["audio"])
	
	match entityData["attenModel"]:
		"inverse":
			attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
		"inverseSquare":
			attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_SQUARE_DISTANCE
		"log":
			attenuation_model = AudioStreamPlayer3D.ATTENUATION_LOGARITHMIC
		"disabled":
			attenuation_model = AudioStreamPlayer3D.ATTENUATION_DISABLED
	
	volume_db = entityData["volume_db"]
	unit_size = entityData["unit_size"]
	max_db = entityData["maxDB"]
	pitch_scale = entityData["pitchScale"]
	autoplay = entityData["autoplay"]
	max_distance = entityData["distance"]
	max_polyphony = entityData["polyphony"] # probs not gonna be used
	panning_strength = entityData["panningStrength"]
	
	match entityData["bus"]:
		"master":
			bus = "Master"
		"music":
			bus = "Music"
		"vo":
			bus = "VO"
		"sfx":
			bus = "SFX"
	
	emission_angle_enabled = entityData["emissionAngled"]
	emission_angle_degrees = entityData["emissionAngleDegress"]
	emission_angle_filter_attenuation_db = entityData["emissionAngleAttenDB"]
	
	attenuation_filter_cutoff_hz = entityData["attenCutoffHz"]
	attenuation_filter_db = entityData["attenDB"]
	
	match entityData["doppler"]:
		"disabled":
			doppler_tracking = AudioStreamPlayer3D.DOPPLER_TRACKING_DISABLED
		"idle":
			doppler_tracking = AudioStreamPlayer3D.DOPPLER_TRACKING_IDLE_STEP
		"physics":
			doppler_tracking = AudioStreamPlayer3D.DOPPLER_TRACKING_PHYSICS_STEP
	
	position.x = entityData["position"][0]
	position.y = entityData["position"][1]
	position.z = entityData["position"][2]


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
