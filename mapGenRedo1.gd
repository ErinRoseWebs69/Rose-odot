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
	if Engine.is_editor_hint():
		pass
	else:
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
		GenMats.getMaterials()
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
	#print("world")
	pass

func generateMesh():
	if mapData == null:
		print("Error: map file is null, or something was not formatted correctly")
		return
		
	if mapData.has("geo"):
		print(mapData["geo"])
		for room in mapData["geo"]:
			print("room: " + room)
			var mi = MeshInstance3D.new()
			
			
			var room_mesh = ResourceLoader.load("res://maps/"+room)
			mi.mesh = room_mesh
			
			for i in mi.get_surface_override_material_count():
				var mat = mi.get_active_material(i).resource_name
				mi.set_surface_override_material(i, ResourceLoader.load("res://materials/"+mat+".tres"))
				
				#TEMPORARY
				#mi.set_surface_override_material(i, ResourceLoader.load("res://materials/test_3.tres"))
			
			mi.name = room
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
			
			world.add_child(mi)
			mi.create_trimesh_collision()
			#mi.rotation = Vector3(PI/2,0,0)
		
	else:
		print("Error reading file: geometry not present")

### ENTITIES TO ADD
# prop_dynamic (requires fixing .gltf, from there just use gltf as standard)
# world_environment (WorldEnvironment node) TODO: setup other features for this entity
# light_spot (spotlight)
# prop_physics (Rigidbody3D)
# move_linear (model with moving code) NOTE: would allow options for different lerp types
# door_rotating (model with rotation code) NOTE: rotatioinPoint is relative to object's position. for example: origin is [4,0,4], and rotation point is [-3,0,0]. the actual rotation point would then be [1,0,4].
# npc_generic (a generic NPC with no movement code or anything)
# while i will be making some general NPCs, most of them will be dedicated to the current game. 

func generateEntities():
	if mapData.has("point_entities"):
		for entity in mapData["point_entities"]:
			var pointEnts = mapData["point_entities"][entity]
			match pointEnts["type"]:
				
				## Single Instance Entities (if multiple exist, use only first instance found in file)
				"player_start":
					var ent = Node3D.new()
					ent.position = arrayToVector3(pointEnts["position"])
					ent.name = "player_start"
					world.add_child(ent)
					player.position = arrayToVector3(pointEnts["position"])
					player.rotation_degrees = arrayToVector3(pointEnts["rotation"])
				"world_environment":
					var ent = world_environment.new(pointEnts, world)
					world.add_child(ent)
				
				## Multi-Instance Entities
				# lights
				"light":
					var ent = light.new(pointEnts, world)
					world.add_child(ent)
				
				# props
				"prop_static":
					var ent = prop_static.new(pointEnts, world)
					world.add_child(ent)
				"move_linear":
					var ent = move_linear.new(pointEnts, world)
					world.add_child(ent)
				"door_rotating":
					var ent = prop_static.new(pointEnts, world)
					world.add_child(ent)
				
				# misc.
				"audio_streamer":
					var ent = audio_streamer.new(pointEnts, world) #TODO: implement looping and such
					world.add_child(ent)
				
				## "Brush" Entities
				"trigger_multiple":
					var ent = trigger_multiple.new(pointEnts, world)
					world.add_child(ent)
				"trigger_multiple_sphere": #TODO: actually implement
					var ent = trigger_multiple.new(pointEnts, world)
					world.add_child(ent)
				
				## Temporary Entities (used for testing)
				"cube":
					var ent = tempCube.new()
					world.add_child(ent)
			
			# Sets a default player position and rotation if player_start is not found in file
			if not world.has_node("player_start"):
				player.position = Vector3(0.0,0.0,0.0)
				player.rotation_degrees = Vector3(0.0,0.0,0.0)
				
func arrayToVector3(array) -> Vector3:
	var vec3:Vector3
	vec3.x = array[0]
	vec3.y = array[1]
	vec3.z = array[2]
	return vec3
