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
		#world.rotation = Vector3(-PI/2,0,0)
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
	if mapData == null:
		print("Error: map file is null, or something was not formatted correctly")
		return
		
	if mapData.has("geo"):
		print(mapData["geo"])
		for room in mapData["geo"]:
			print("room: " + room)
			var mi = MeshInstance3D.new()
			
			
			print("res://maps/"+room)
			mi.mesh = ResourceLoader.load("res://maps/"+room)
			
			mi.name = room
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
			
			world.add_child(mi)
			mi.create_trimesh_collision()
			mi.rotation = Vector3(PI/2,0,0)
		
	else:
		print("Error reading file: geometry not present")

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
