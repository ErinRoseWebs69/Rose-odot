extends Area3D

class_name trigger_multiple

#var targetEntity
var world
var bodyNode
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
	
	add_child(col)

func _process(_delta):
	pass
	#for body in get_overlapping_bodies():
		#bodyNode = body
		#print(bodyNode)

#func _connectSignals(outputData):
	#for data in outputData:
		#var input = outputData[data]["input"]
		#var targetEntity = world.get_node(outputData[data]["targetEntity"])
		#var output = outputData[data]["output"]
		#var params = outputData[data]["parameters"]
		#
		## Get input type
		#match input:
			#"onEntered":
				#body_entered.connect(_on_body_entered)
			#"onExited":
				#body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		for data in outputData:
			var input = outputData[data]["input"]
			if input == "onEntered":
				var targetEntity = world.get_node(outputData[data]["targetEntity"])
				if is_instance_valid(targetEntity):
					var output = outputData[data]["output"]
					var params = outputData[data]["parameters"]
					targetEntity.call(output, params)

func _on_body_exited(body):
	if body.is_in_group("player"):
		for data in outputData:
			var input = outputData[data]["input"]
			if input == "onExited":
				var targetEntity = world.get_node(outputData[data]["targetEntity"])
				if is_instance_valid(targetEntity):
					var output = outputData[data]["output"]
					var params = outputData[data]["parameters"]
					targetEntity.call(output, params)
