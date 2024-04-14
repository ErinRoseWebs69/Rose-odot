extends Area3D

class_name trigger_multiple_sphere

#var targetEntity
var world
var filterType:String
var filter:String
var outputData
var validInputs = [
	"onEntered",
	"onExited"
]
var validOutputs = [
	"enable",
	"disable"
]

func _init(entityData, worldNode):
	# Define the world node
	world = worldNode
	# Generate trigger data, such as shape and size
	var col = CollisionShape3D.new()
	var colShape = SphereShape3D.new()
	colShape.radius = entityData["radius"]
	position.x = entityData["position"][0]
	position.y = entityData["position"][1]
	position.z = entityData["position"][2]
	name = entityData["name"]
	col.shape = colShape
	
	# Create signals if the entity has any defined outputs
	if entityData.has("outputs"):
		outputData = entityData["outputs"]
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)
	
	if entityData.has("collisionLayers"):
		print("i have col layers")
	
	print(entityData["collisionLayers"])
	
	for layer in entityData["collisionLayers"]:
		match layer:
			"player":
				set_collision_layer_value(2, true)
			"ai":
				set_collision_layer_value(3, true)
			"physics":
				set_collision_layer_value(4, true)
	
	filterType = entityData["filterType"]
	filter = entityData["filter"]
	
	add_child(col)

func _process(_delta):
	pass

func _on_body_entered(body):
	match filterType:
		"none":
			if body:
				outputCall("onEntered")
		"name":
			if body.name == filter:
				outputCall("onEntered")
		"group":
			if body.is_in_group(filter):
				outputCall("onEntered")
		"class":
			if body.get_class() == filter:
				outputCall("onEntered")

func _on_body_exited(body):
	match filterType:
		"none":
			if body:
				outputCall("onExited")
		"name":
			if body.name == filter:
				outputCall("onExited")
		"group":
			if body.is_in_group(filter):
				outputCall("onExited")
		"class":
			if body.get_class() == filter:
				outputCall("onExited")

func outputCall(type):
	for data in outputData:
		var input = outputData[data]["input"]
		if input == type:
			var targetEntity = world.get_node(outputData[data]["targetEntity"])
			if is_instance_valid(targetEntity):
				var output = outputData[data]["output"]
				var params = outputData[data]["parameters"]
				targetEntity.call(output, params)
