extends MeshInstance3D

class_name prop_static

func _init(entityData, world):
	name = "prop_static"
	mesh = ResourceLoader.load("res://models/"+entityData["model"])
	
	if entityData["collisions"] == true:
		create_trimesh_collision()
	
	position.x = entityData["position"][0]
	position.y = entityData["position"][1]
	position.z = entityData["position"][2]
	
	rotation_degrees.x = entityData["rotation"][0]
	rotation_degrees.y = entityData["rotation"][1]
	rotation_degrees.z = entityData["rotation"][2]
	
	for i in get_surface_override_material_count():
		if get_active_material(i) != null:
			var mat = get_active_material(i).resource_name
			set_surface_override_material(i, ResourceLoader.load("res://materials/"+mat+".tres"))

# Called when the node enters the scene tree for the first time.
func _ready():
	return


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
