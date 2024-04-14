extends Area3D

class_name trigger_multiple

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
	var colShape = BoxShape3D.new()
	colShape.size.x = entityData["size"][0]
	colShape.size.y = entityData["size"][1]
	colShape.size.z = entityData["size"][2]
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
	
	set_collision_mask_value(1, false)
	for layer in entityData["collisionLayers"]:
		match layer:
			"player":
				set_collision_mask_value(2, true)
			"ai":
				set_collision_mask_value(3, true)
			"physics":
				set_collision_mask_value(4, true)
	
	filterType = entityData["filterType"]
	filter = entityData["filter"]
	
	print("filter data: ", filterType, filter)
	
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
