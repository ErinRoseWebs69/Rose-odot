extends RigidBody3D

class_name prop_physics

var worldNode

func _init(entityData, world):
	worldNode = world
	
	name = entityData["name"]
	
	position.x = entityData["position"][0]
	position.y = entityData["position"][1]
	position.z = entityData["position"][2]
	
	rotation_degrees.x = entityData["rotation"][0]
	rotation_degrees.y = entityData["rotation"][1]
	rotation_degrees.z = entityData["rotation"][2]
	
	var mi = MeshInstance3D.new()
	
	name = entityData["name"]
	mi.mesh = ResourceLoader.load("res://models/"+entityData["model"])
	mi.name = "collision"
	self.add_child(mi)
	
	mi.create_convex_collision()
	var staticbody = mi.get_child(0)
	var col = CollisionShape3D.new()
	col.shape = staticbody.get_child(0).shape
	self.add_child(col)
	mi.get_child(0).queue_free()
	
	set_collision_layer_value(1, true)
	set_collision_layer_value(4, true)
	
	if entityData["canGrab"] == true:
		add_to_group("grabbable")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
