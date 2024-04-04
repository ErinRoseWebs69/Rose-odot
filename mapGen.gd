@tool
extends Node3D
@export var update = false
@export var clearData = false

var mapData = {}
var mi = MeshInstance3D.new()

@export var data_file_path:String
#var data_file_path:String  = "res://planeGenerationTest.json"

# Called when the node enters the scene tree for the first time.
func _ready():
	genMap()

func genMap():
	mapData = loadMapJson(data_file_path)
	generateWorldData()
	generateMesh()
	generateEntities()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if update and not clearData:
		genMap()
		print("End map generation!")
		update = false
	elif update and clearData:
		mi.queue_free()
		print("Cleared previously loaded map data.")
		update = false
		clearData = false

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
	pass

func generateMesh():
	if mapData == null:
		print("Error: map file is null, or something was not formatted correctly")
		return
	if mapData.has("geo"):
		#print(mapData["geo"])
		var mesh = ArrayMesh.new()
		var surface_array = []
		surface_array.resize(Mesh.ARRAY_MAX)
		var vertsArray:PackedVector3Array = []
		var normalsArray:PackedVector3Array = []
		var indicesArray:PackedInt32Array = []
		for tri in mapData["geo"]:
			var tris = mapData["geo"][tri]
			
			### Handle generation of tris
			print("vert data")
			var verts = tris["vertices"]
			if verts == null:
				print("Error: vertice data is empty")
				return
			
			var indVerts: PackedVector3Array
			var normalCalcs = [0,0,0]
			for i in verts:
				var vertexPoint:Vector3
				vertexPoint.x = i[0]
				vertexPoint.y = i[1]
				vertexPoint.z = i[2]
				vertsArray.append(vertexPoint)
			print(vertsArray)
			
			indicesArray = (
				tris["indices"]
			)
			
			print(tris["vertexNormal"])
			
			var normals:PackedVector3Array
			#var normalPoint=Vector3(tris["vertexNormal"][0],tris["vertexNormal"][1],tris["vertexNormal"][2])
			for i in tris["vertexNormal"]:
				var pointNormal:Vector3
				pointNormal.x = i[0]
				pointNormal.y = i[1]
				pointNormal.z = i[2]
				normalsArray.append(pointNormal)
			print(normalsArray)
			
			### Handle materials
			
			#vertsArray.append(indVerts)
			#indicesArray.append(indices)
			#normalsArray.append(normals)
			
		if mi == null:
			mi = MeshInstance3D.new()
		surface_array[Mesh.ARRAY_VERTEX] = vertsArray
		surface_array[Mesh.ARRAY_INDEX] = indicesArray
		surface_array[Mesh.ARRAY_NORMAL] = normalsArray
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,surface_array)
		mi.mesh = mesh
		add_child(mi)
	else:
		print("Error reading file: geometry not present")

#func calcNormals(a:Vector3,b:Vector3,c:Vector3) -> Array:
	#var edge1 = b - c
	#var edge2 = c - a
	#var normal = edge1.cross(edge2).normalized()
	#return normal

func calcVertexNorms(vertices,indices,face_normal) -> PackedVector3Array:
	var vertex_normals = []
	
	for vertex in vertices:
		vertex_normals.append(Vector3.ZERO)
	
	for i in range(face_normal.size()):
		var face_normals = face_normal[i]
		var vertex_index = indices[i*3]
		vertex_normals[vertex_index] += face_normals
		vertex_normals[vertex_index+1] += face_normals
		vertex_normals[vertex_index+2] += face_normals
	
	for i in range(vertex_normals.size()):
		vertex_normals[i] = vertex_normals[i].normalized()
	return vertex_normals

func generateEntities():
	pass
