@tool
extends Node

var mats:Array = ["res://materials/engine/missingMaterial.tres"]
var materialDirecory = "res://materials/"
var materialPath:String

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func getMaterials():
	var dir = DirAccess.open("res://materials/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				#print("Found directory: " + file_name)
				pass
			else:
				#print("Found file: " + file_name)
				if file_name.get_extension() == "rdm":
					genMaterials(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func genMaterials(matFile):
	var matObject:Array[StandardMaterial3D]
	# Check if a Godot material already exists
	var matFilePath = "res://materials/" + matFile
	print(matFilePath)
	var matFileName = matFile.left(matFile.length() - 4)
	print(matFileName)
	var godotMatFilePath = "res://materials/" + matFileName + ".tres"
	var godotMat = matFileName + ".tres"
	if FileAccess.file_exists(matFilePath):
		# If a Godot material does not exist, create new material
		var material = StandardMaterial3D.new()
		materialPath = matFilePath
		if FileAccess.file_exists(matFilePath):
			#print(matFilePath, " exists!")
			var file = FileAccess.open(matFilePath, FileAccess.READ)
			var fileData = JSON.parse_string(file.get_as_text())
			var image = CompressedTexture2D.new()
			## Generate material from file
			
			# Transparency
			if fileData.has("alphaMode"):
				match fileData["alphaMode"]:
					"disabled":
						material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
					"alpha":
						material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
					"alphaScissor":
						material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
					"alphaHash":
						material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_HASH
					"depthPrePass":
						material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
			else:
				material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
			
			# Shading
			if fileData.has("shadeMode"):
				match fileData["shadeMode"]:
					"unshaded":
						material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
					"pixel":
						material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
					"vertex":
						material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
			else:
				#print("Error: ", matFilePath, " does not have a defined shade mode. Defaulting to 'Per-Pixel'")
				material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
			if fileData.has("diffuseMode"):
				match fileData["diffuseMode"]:
					0:
						material.diffuse_mode = BaseMaterial3D.DIFFUSE_BURLEY
					1:
						material.diffuse_mode = BaseMaterial3D.DIFFUSE_LAMBERT
					2:
						material.diffuse_mode = BaseMaterial3D.DIFFUSE_LAMBERT_WRAP
					3:
						material.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
			else:
				#print("Error: ", matFilePath, " does not have a defined diffuse mode. Defaulting to 'Burley'.")
				material.diffuse_mode = BaseMaterial3D.DIFFUSE_BURLEY
			
			# Vertex Color
			if fileData.has("vertexColorAsAlbedo"):
				material.vertex_color_use_as_albedo = fileData["vertexColorAsAlbedo"]
			else:
				material.vertex_color_use_as_albedo = false
			if fileData.has("vertexColorIsSRGB"):
				material.vertex_color_is_srgb = fileData["vertexColorIsSRGB"]
			else:
				material.vertex_color_is_srgb = false
			
			# Albedo
			if fileData.has("albedo"):
				material.albedo_texture = ResourceLoader.load(materialDirecory + fileData["albedo"])
				#material.albedo_texture = fileData["albedo"]
			if fileData.has("baseColor"):
				material.albedo_color.r = fileData["baseColor"][0]
				material.albedo_color.g = fileData["baseColor"][1]
				material.albedo_color.b = fileData["baseColor"][2]
			
			# Height
			if fileData.has("heightMap"):
				material.heightmap_enabled = true
				material.heightmap_texture = ResourceLoader.load(materialDirecory + fileData["heightMap"])
				if fileData.has("heightMapScale"):
					material.heightmap_scale = fileData["heightMapScale"]
				else:
					#print("Error: ", file, " does not have a defined heightmap scale. Defaulting to '5.0'.")
					material.heightmap_scale = 5.0
				if fileData.has("heightParallax"):
					material.heightmap_deep_parallax = true
				if fileData.has("heightFlipTangent"):
					material.heightmap_flip_tangent = true
				if fileData.has("heightFlipBinormal"):
					material.heightmap_flip_binormal = true
				if fileData.has("heightFlipTexture"):
					material.heightmap_flip_texture = true
			
			# Refraction
			if fileData.has("refractMap"):
				material.refraction_enabled = true
				material.refraction_texture = ResourceLoader.load(materialDirecory + fileData["refractMap"])
				if fileData.has("refractMapScale"):
					material.refraction_scale = fileData["refractionMapScale"]
				else:
					#print("Error: ", matFilePath, " does not have a defined refract scale. Defaulting to '0.05'.")
					material.refraction_scale = 0.05
				if fileData.has("refractChannel"):
					match fileData["refractChannel"]:
						"alpha":
							material.refraction_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_ALPHA
						"gray":
							material.refraction_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GRAYSCALE
						"red":
							material.refraction_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
						"green":
							material.refraction_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GREEN
						"blue":
							material.refraction_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_BLUE
				else:
					print("Error: ", file, " does not have a defined refrection texture channel. Defaulting to 'red'")
			
			# Detail
			if fileData.has("detail"):
				if fileData["detail"] == true:
					material.detail_enabled = true
					if fileData.has("detailMask"):
						material.detail_mask = ResourceLoader.load(materialDirecory + fileData["detailMask"])
					if fileData.has("detailAlbedo"):
						material.detail_albedo = ResourceLoader.load(materialDirecory + fileData["detailAlbedo"])
					if fileData.has("detailNormal"):
						material.detail_normal = ResourceLoader.load(materialDirecory + fileData["detailNormal"])
					if fileData.has("detailBlendMode"):
						match fileData["detailBlendMode"]:
							"add":
								material.detail_blend_mode = BaseMaterial3D.BLEND_MODE_ADD
							"mix":
								material.detail_blend_mode = BaseMaterial3D.BLEND_MODE_MIX
							"multiply":
								material.detail_blend_mode = BaseMaterial3D.BLEND_MODE_MUL
							"subtract":
								material.detail_blend_mode = BaseMaterial3D.BLEND_MODE_SUB
					else:
						material.detail_blend_mode = BaseMaterial3D.BLEND_MODE_ADD
			
			# UV Transforms
			if fileData.has("uv1Scale"):
				material.uv1_scale = arrayToVec3(fileData["uv1Scale"])
			else:
				material.uv1_scale = Vector3(1,1,1)
			if fileData.has("uv1Offset"):
				material.uv1_offset = arrayToVec3(fileData["uv1Offset"])
			else:
				material.uv1_offset = Vector3(0,0,0)
			if fileData.has("uv1Triplanar"):
				if fileData["uv1Triplanar"] == true:
					material.uv1_triplanar = true
					if fileData.has("uv1TriplanarSharpness"):
						material.uv1_triplanar_sharpness = fileData["uv1TrisplanarSharpness"]
					else:
						material.uv1_triplanar_sharpness = 1.00
					if fileData.has("uv1WorldTriplanar"):
						material.uv1_world_triplanar = fileData["uv1WorldTriplanar"]
					else:
						material.uv1_world_triplanar = false
				else:
					material.uv1_triplanar = false
			if fileData.has("uv2Scale"):
				material.uv2_scale = arrayToVec3(fileData["uv2Scale"])
			else:
				material.uv2_scale = Vector3(1,1,1)
			if fileData.has("uv2Offset"):
				material.uv2_offset = arrayToVec3(fileData["uv2Offset"])
			else:
				material.uv2_offset = Vector3(0,0,0)
			if fileData.has("uv2Triplanar"):
				if fileData["uv2Triplanar"] == true:
					material.uv2_triplanar = true
					if fileData.has("uv2TriplanarSharpness"):
						material.uv2_triplanar_sharpness = fileData["uv2TrisplanarSharpness"]
					else:
						material.uv2_triplanar_sharpness = 1.00
					if fileData.has("uv2WorldTriplanar"):
						material.uv2_world_triplanar = fileData["uv2WorldTriplanar"]
					else:
						material.uv2_world_triplanar = false
				else:
					material.uv2_triplanar = false
			
			# Sampling
			if fileData.has("sampling"):
				match fileData["sampling"]:
					"nearest":
						material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
					"linear":
						material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
					"nearMipMap":
						material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
					"linMipMap":
						material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
					"nearMipAn":
						material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS_ANISOTROPIC
					"linMipAn":
						material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
			else:
				material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
			if fileData.has("repeating"):
				material.texture_repeat = fileData["repeating"]
			else:
				material.texture_repeat = true
			
			# Shadows
			if fileData.has("recieveShadows"):
				material.disable_receive_shadows = fileData["recieveShadows"]
			else:
				material.disable_receive_shadows = false
			if fileData.has("opacityShadow"):
				material.shadow_to_opacity = fileData["opacityShadow"]
			else:
				material.shadow_to_opacity = false
			
			# Billboard
			if fileData.has("billboardMode"):
				match fileData["billboardMode"]:
					"disabled":
						material.billboard_mode = BaseMaterial3D.BILLBOARD_DISABLED
					"enabled":
						material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
					"fixedY":
						material.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
					"particle":
						material.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
				if not fileData["billboardMode"] == "disabled":
					if fileData.has("billboardKeepScale"):
						material.billboard_keep_scale = fileData["billboardKeepScale"]
					else:
						material.billboard_keep_scale = false
			
			# Grow
			if fileData.has("growAmount"):
				material.grow = true
				material.grow_amount = fileData["growAmount"]
			else:
				material.grow = false
			
			# Transform
			if fileData.has("fixedSize"):
				material.fixed_size = fileData["fixedSize"]
			if fileData.has("pointSize"):
				material.use_point_size = true
				material.point_size = fileData["pointSize"]
			else:
				material.use_point_size = false
			if fileData.has("useParticleTrails"):
				material.use_particle_trails = fileData["useParticleTrails"]
			
			# Proximity Fade
			if fileData.has("proxFadeDistance"):
				material.proximity_fade_enabled = true
				material.proximity_fade_distance = fileData["proxFadeDistance"]
			else:
				material.proximity_fade_enabled = false
			
			# Distance Fade
			if fileData.has("distanceFade"):
				match fileData["distanceFade"]:
					"disabled":
						material.distance_fade_mode = BaseMaterial3D.DISTANCE_FADE_DISABLED
					"pixelAlpha":
						material.distance_fade_mode = BaseMaterial3D.DISTANCE_FADE_PIXEL_ALPHA
					"pixelDither":
						material.distance_fade_mode = BaseMaterial3D.DISTANCE_FADE_PIXEL_DITHER
					"objectDither":
						material.distance_fade_mode = BaseMaterial3D.DISTANCE_FADE_OBJECT_DITHER
				if fileData.has("distanceFadeMin"):
					material.distance_fade_min_distance = fileData["distanceFadeMin"]
				else:
					material.distance_fade_min_distance = 0
				if fileData.has("distanceFadeMax"):
					material.distance_fade_max_distance = fileData["distanceFadeMax"]
				else:
					material.distance_fade_max_distance = 10
			else:
				material.distance_fade_mode = BaseMaterial3D.DISTANCE_FADE_DISABLED
			
			# Render Priority
			if fileData.has("renderPriority"):
				material.render_priority = fileData["renderPriority"]
			else:
				material.render_priority = 0
			
			# Save material to Godot file
			ResourceSaver.save(material, godotMatFilePath, ResourceSaver.FLAG_COMPRESS)
			
			# Name the material (currently non-functional)
			material.resource_name = matFileName
			
			# Load the material object to be added to an array
			var savedMat:StandardMaterial3D = ResourceLoader.load(godotMatFilePath)
			
			if not mats.has(godotMatFilePath):
				mats.append(godotMatFilePath)
	else:
		# Send back the 'missingTexture' material
		#if mat == "":
			#print("Uknown material. Setting material to 'missingMaterial'.")
		#else:
			#print(materialPath, " does not exist! Setting material to 'missingMaterial'.")
		#var missingMaterial = "res://materials/engine/missingMaterial.tres"
		#if not mats.has(missingMaterial):
			#mats.push_front(missingMaterial)
		pass
				
	
		for i in mats:
			matObject.append(ResourceLoader.load("res://materials/" + matFileName + ".tres"))
	#print(mats)
	return mats

func arrayToVec3(array) -> Vector3:
	var vec3:Vector3
	vec3.x = array[0]
	vec3.y = array[1]
	vec3.z = array[2]
	return vec3
