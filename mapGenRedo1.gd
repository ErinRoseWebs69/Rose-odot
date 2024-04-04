@tool
extends Node3D
@export var update = false

var mapData = {}
@onready var world = $world
#var mi = MeshInstance3D.new()
var colShape = ConvexPolygonShape3D.new()

@export var map_file:String
var data_file_path:String

@onready var player = $player

# Called when the node enters the scene tree for the first time.
func _ready():
	genMap()

func genMap():
	if not world.get_children().is_empty():
		for i in world.get_children():
			### Do differently, as this could crash the engine if Nodes are actively doing anything
			# i mighta fixed it lol
			i.free()
		print("Cleared previous map.")
	
	data_file_path = "res://maps/" + map_file
	mapData = loadMapJson(data_file_path)
	#world.rotate_x(PI/2)
	if world.get_children().is_empty():
		generateWorldData()
		generateMesh()
		generateEntities()
		world.rotation = Vector3(-PI/2,0,0)
		print("Map generation complete.")

func clearMap():
	if not world.get_children().is_empty():
		for i in world.get_children():
			i.queue_free()
		print("Cleared previous map.")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if update:
		genMap()
		update = false
	#elif update and not world == null:
		#clearMap()
		#print("Cleared previously loaded map data.")
		#update = false
		#clearData = false

func loadMapJson(filePath : String):
	if FileAccess.file_exists(filePath):
		var dataFile = FileAccess.open(filePath, FileAccess.READ)
		var parsedResult = JSON.parse_string(dataFile.get_as_text())
		
		if parsedResult is Dictionary:
			return parsedResult
		else:
			print("Error reading file: JSON formatting is incorrect")
	else:
		print("File doesn't exist")

func generateWorldData():
	print("world")

func generateMesh():
	## Handle map mesh generation
	var mi = MeshInstance3D.new()
		
	if mapData == null:
		print("Error: map file is null, or something was not formatted correctly")
		return
		
	if mapData.has("geo"):
		var mesh = ArrayMesh.new()
		var surface_array = []
		surface_array.resize(Mesh.ARRAY_MAX)
		var vertsArray: PackedVector3Array = []
		var vertex_normals
		var normalsArray: PackedVector3Array = []
		var indicesArray: PackedInt32Array = []
		var vertex_index = 0
		
		var vertexMap:Dictionary = {}
		var currentIndex = 0
		
		var matsArray:Array
		var texUVs:PackedVector2Array
		var matsAmount:int
		var matIndexJSON:Array
		var mapMatIndex = 0
		
		for room in mapData["geo"]:
			print("room: " + room)
			var geo = mapData["geo"]
			for materialIndex in geo[room]:
				print("matIndex: " + materialIndex)
				var roomData = geo[room]
				for tri in roomData[materialIndex]:
					print(tri)
					# Handle generation of tris
					var tris = roomData[materialIndex][tri]
					var verts = tris["vertices"]
					var uvs = tris["uv_coords"]
					
					# Generate separate mesh array per material
					if verts == null:
						print("Error: vertice data is empty")
						return
					
					# Add vertices to vertex array
					for i in verts:
						var vertexPoint = Vector3(i[0], i[1], i[2])
						vertsArray.append(vertexPoint)
					
					# Calculate face normal for the triangle
					var v0 = Vector3(verts[0][0], verts[0][1], verts[0][2])
					var v1 = Vector3(verts[1][0], verts[1][1], verts[1][2])
					var v2 = Vector3(verts[2][0], verts[2][1], verts[2][2])
					
					var edge1 = v1 - v0
					var edge2 = v2 - v0
					var face_normal = edge1.cross(edge2).normalized()
					
					# Add indices to indices array
					indicesArray.append(vertex_index)
					indicesArray.append(vertex_index + 1)
					indicesArray.append(vertex_index + 2)
					
					#uvs.append(tris.get("uv_coords", []))
					for uv in uvs:
						var vec2:Vector2
						vec2.x = uv[0]
						vec2.y = uv[1]
						texUVs.append(vec2)
					
					vertex_index += 3
					
					# Add face normal to normals array for each vertex of the triangle
					for i in range(3):
						normalsArray.append(face_normal)
					
					## Handle getting materials from each tri
					var material = tris["material_name"]
					if not matsArray.has(material):
						matsArray.append(material)
						#matsAmount += 1
			
					# Calculate vertex normals based on face normals
					vertex_normals = calcVertexNorms(vertsArray, indicesArray, normalsArray)
					
					
				surface_array[Mesh.ARRAY_VERTEX] = vertsArray
				surface_array[Mesh.ARRAY_INDEX] = indicesArray
				surface_array[Mesh.ARRAY_NORMAL] = vertex_normals
				surface_array[Mesh.ARRAY_TEX_UV] = texUVs
				
				mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
					
				mapMatIndex += 1
			mi.mesh = mesh
			
			# Call on a script to generate Godot materials
			var usedMats = GenMats.genMaterials(matsArray)
			
			# Apply materials to mesh
			var matIndex = 0
			for i in usedMats:
				mi.set_surface_override_material(matIndex, ResourceLoader.load(usedMats[matIndex]))
				matIndex += 1
			
			mi.name = room
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
			
			#mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
			world.add_child(mi)
			mi.create_trimesh_collision()
		
	else:
		print("Error reading file: geometry not present")

func calcVertexNorms(vertices: PackedVector3Array, indices: PackedInt32Array, face_normals: PackedVector3Array) -> PackedVector3Array:
	var vertex_normals = []
	
	# Initialize vertex normals
	for i in vertices:
		vertex_normals.append(Vector3.ZERO)
	
	# Accumulate face normals for each vertex
	for i in range(face_normals.size()):
		var face_normal = face_normals[i]
		var vertex_index = indices[i]
		vertex_normals[vertex_index] -= face_normal
	
	# Normalize vertex normals
	for i in range(vertex_normals.size()):
		vertex_normals[i] = vertex_normals[i].normalized()
	
	return vertex_normals

func generateEntities():
	if mapData.has("point_entities"):
		for entity in mapData["point_entities"]:
			var pointEnts = mapData["point_entities"][entity]
			match pointEnts["type"]:
				"light":
					var ent = light.new(pointEnts, world)
					#ent.entityData = pointEnts
					world.add_child(ent)
				"player_start":
					var ent = Node3D.new()
					ent.position = arrayToVector3(pointEnts["position"])
					ent.name = "player_start"
					world.add_child(ent)
					player.position = arrayToVector3(pointEnts["position"])
					player.rotation_degrees = arrayToVector3(pointEnts["rotation"])
				"trigger_multiple":
					var ent = trigger_multiple.new(pointEnts, world)
					world.add_child(ent)
				"cube":
					var ent = tempCube.new()
					world.add_child(ent)
			if not world.has_node("player_start"):
				player.position = Vector3(0.0,0.0,0.0)
				player.rotation_degrees = Vector3(0.0,0.0,0.0)
	### REMOVE LATER
	#var trigger = Area3D.new()
	#var triggerCol = CollisionShape3D.new()
	#var triggerColShape = BoxShape3D.new()
	#trigger.position = Vector3(0,-1.5,2.5)
	#triggerColShape.size = Vector3(16,5,1)
	#triggerCol.shape = triggerColShape
	#trigger.rotation_degrees = Vector3(-90,0,0)
	#world.add_child(trigger)
	#trigger.add_child(triggerCol)

func arrayToVector3(array) -> Vector3:
	var vec3:Vector3
	vec3.x = array[0]
	vec3.y = array[1]
	vec3.z = array[2]
	return vec3
