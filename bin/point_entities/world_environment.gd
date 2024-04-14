extends WorldEnvironment

class_name world_environment

func _init(entityData, world):
	var env = Environment.new()
	
	### BACKGROUND
	match entityData["backgroundMode"]:
		"clear":
			env.background_mode = Environment.BG_CLEAR_COLOR
		"color":
			env.background_mode = Environment.BG_COLOR
			env.background_color = entityData["backgroundColor"]
		#"sky":
			#env.background_mode = Environment.BG_SKY
		"canvas":
			env.background_mode = Environment.BG_CANVAS
			env.background_canvas_max_layer = entityData["backgroundCanvasMaxLayer"]
		"keep":
			env.background_mode = Environment.BG_KEEP
		"cam":
			env.background_mode = Environment.BG_KEEP
			env.background_camera_feed_id = entityData["backgroundCamID"]
		"max":
			env.background_mode = Environment.BG_MAX
	
	env.background_energy_multiplier = entityData["backgroundEnergy"]
	
	### AMBIENT LIGHT
	match entityData["ambientLightSource"]:
		"background":
			env.ambient_light_source = Environment.AMBIENT_SOURCE_BG
		"color":
			env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		#"sky":
			#env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
			#env.ambient_light_sky_contribution = entityData["ambLightSkyCont"]
		"disabled":
			env.ambient_light_source = Environment.AMBIENT_SOURCE_DISABLED
	env.ambient_light_color = entityData["ambLightColor"]
	env.ambient_light_energy = entityData["ambLightEnergy"]
	
	### REFRACTED LIGHT
	match entityData["refractLightSource"]:
		"background":
			env.reflected_light_source = Environment.REFLECTION_SOURCE_BG
		#"sky":
			#env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
		"disabled":
			env.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	
	### TONEMAP
	match entityData["tonemapMode"]:
		"linear":
			env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
		"reinhard":
			env.tonemap_mode = Environment.TONE_MAPPER_REINHARDT
		"filmic":
			env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
		"aces":
			env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = entityData["tonemapExposure"]
	env.tonemap_white = entityData["tonemapWhite"]
	
	### SSR
	if entityData["ssrEnabled"] == true:
		env.ssr_enabled = true
		env.ssr_max_steps = entityData["ssrMaxSteps"]
		env.ssr_fade_in = entityData["ssrFadeIn"]
		env.ssr_fade_out = entityData["ssrFadeOut"]
		env.ssr_depth_tolerance = entityData["ssrDepthTolerance"]
	else:
		env.ssr_enabled = false
	
	### SSAO
	if entityData["ssaoEnabled"] == true:
		env.ssao_enabled = true
		env.ssao_radius = entityData["ssaoRadius"]
		env.ssao_intensity = entityData["ssaoIntensity"]
		env.ssao_power = entityData["ssaoPower"]
		env.ssao_detail = entityData["ssaoDetail"]
		env.ssao_horizon = entityData["ssaoHorizon"]
		env.ssao_sharpness = entityData["ssaoSharpness"]
		env.ssao_light_affect = entityData["ssaoLightAffect"]
		env.ssao_ao_channel_affect = entityData["ssaoAOChannelAffect"]
	else:
		env.ssao_enabled = false
	
	### SSIL
	if entityData["ssilEnabled"] == true:
		env.ssil_enabled = true
		env.ssil_radius = entityData["ssilRadius"]
		env.ssil_intensity = entityData["ssilIntensity"]
		env.ssil_sharpness = entityData["ssilSharpness"]
		env.ssil_normal_rejection = entityData["ssilNormalRejection"]
	else:
		env.ssil_enabled = false
	
	### SDFGI
	if entityData["sdfgiEnabled"] == true:
		env.sdfgi_enabled = true
		env.sdfgi_use_occlusion = entityData["sdfgiUseOcclusion"]
		env.sdfgi_read_sky_light = entityData["sdfgiReadSkyLight"]
		env.sdfgi_bounce_feedback = entityData["sdfgiBounceFeedback"]
		env.sdfgi_cascades = entityData["sdfgiCascades"]
		env.sdfgi_min_cell_size = entityData["sdfgiMinCellSize"]
		env.sdfgi_cascade0_distance = entityData["sdfgiCascade0Distance"]
		env.sdfgi_max_distance = entityData["sdfgiMaxDistance"]
		match entityData["sdfgiYScale"]:
			"50%":
				env.sdfgi_y_scale = Environment.SDFGI_Y_SCALE_50_PERCENT
			"75%":
				env.sdfgi_y_scale = Environment.SDFGI_Y_SCALE_75_PERCENT
			"100%":
				env.sdfgi_y_scale = Environment.SDFGI_Y_SCALE_100_PERCENT
		env.sdfgi_energy = entityData["sdfgiEnergy"]
		env.sdfgi_normal_bias = entityData["sdfgiNormalBias"]
		env.sdfgi_probe_bias = entityData["sdfgiProbeBias"]
	else:
		env.sdfgi_enabled = false
	
	### GLOW
	if entityData["glowEnabled"] == true:
		env.glow_enabled = true
		# will fix when i figure out how to access the levels
		#env.glow_
		env.glow_normalized = entityData["glowNormalized"]
		env.glow_intensity = entityData["glowIntensity"]
		env.glow_strength = entityData["glowStrength"]
		env.glow_bloom = entityData["glowBloom"]
		
		match entityData["glowBlendMode"]:
			"additive":
				env.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
			"screen":
				env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SCREEN
			"softlight":
				env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
			"replace":
				env.glow_blend_mode = Environment.GLOW_BLEND_MODE_REPLACE
			"mix":
				env.glow_blend_mode = Environment.GLOW_BLEND_MODE_MIX
		
		env.glow_hdr_threshold = entityData["glowHDRThreshold"]
		env.glow_hdr_scale = entityData["glowHDRScale"]
		env.glow_hdr_luminance_cap = entityData["glowHDRLumCap"]
		env.glow_map_strength = entityData["glowMapStrength"]
		# TODO: handle env.glow_map later, as there's numerous options that i dont know how to handle yet
	else:
		env.glow_enabled = false
	
	### FOG
	if entityData["fogEnabled"] == true:
		env.fog_enabled = true
		env.fog_light_color = entityData["fogLightColor"]
		env.fog_light_energy = entityData["fogLightEnergy"]
		env.fog_sun_scatter = entityData["fogSunScatter"]
		env.fog_density = entityData["fogDensity"]
		env.fog_sky_affect = entityData["fogSkyAffect"]
		env.fog_height = entityData["fogHeight"]
		env.fog_height_density = entityData["fogHeightDensity"]
	else:
		env.fog_enabled = false
	
	### VOLUMETRIC FOG
	if entityData["volFogEnabled"] == true:
		env.volumetric_fog_enabled = true
		env.volumetric_fog_density = entityData["volFogDensity"]
		env.volumetric_fog_albedo = entityData["volFogAlbedoColor"]
		env.volumetric_fog_emission = entityData["volFogEmissionColor"]
		env.volumetric_fog_emission_energy = entityData["volFogEmissionEnergy"]
		env.volumetric_fog_gi_inject = entityData["volFogGIInject"]
		env.volumetric_fog_anisotropy = entityData["volFogAnistropy"]
		env.volumetric_fog_length = entityData["volFogLength"]
		env.volumetric_fog_detail_spread = entityData["volFogDetailSpread"]
		env.volumetric_fog_sky_affect = entityData["volFogSkyAffect"]
		
		if entityData["volFogTempRepoj"] == true:
			env.volumetric_fog_temporal_reprojection_enabled = true
			env.volumetric_fog_temporal_reprojection_amount = entityData["volFogTempRepojAmount"]
		else:
			env.volumetric_fog_temporal_reprojection_enabled = false
	else:
		env.volumetric_fog_enabled = false
	
	### ADJUSTMENTS
	if entityData["adjustmentsEnabled"] == true:
		env.adjustment_enabled = true
		env.adjustment_brightness = entityData["adjustmentBrightness"]
		env.adjustment_contrast = entityData["adjustmentContrast"]
		env.adjustment_saturation = entityData["adjustmentSaturation"]
		# TODO: add color correction
	else:
		env.adjustment_enabled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
