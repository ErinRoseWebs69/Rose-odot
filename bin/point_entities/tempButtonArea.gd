extends Area3D

class_name testButtonArea

var outputData
var resetTime:float
var world
var requiresHold:bool
var canPress:bool
var timer = Timer.new()

func _init(entityData, worldNode):
	world = worldNode
	name = entityData["name"]
	
	position.x = entityData["position"][0]
	position.y = entityData["position"][1]
	position.z = entityData["position"][2]
	
	resetTime = entityData["resetTime"]
	
	var col = CollisionShape3D.new()
	var colShape = BoxShape3D.new()
	colShape.size = Vector3(1,1,1)
	col.shape = colShape
	self.add_child(col)
	add_to_group("interactable")
	
	if resetTime < 0.0:
		requiresHold = false
		timer.wait_time = resetTime
		self.add_child(timer)
		timer.start()
		timer.connect("timeout", _buttonReleased())
	else: requiresHold = true
	
	# Create signals if the entity has any defined outputs
	if entityData.has("outputs"):
		outputData = entityData["outputs"]

func press(pressState):
	if pressState == "press":
		if requiresHold == false:
			canPress == false
		_buttonPressed()
	elif pressState == "release":
		_buttonReleased()

func _buttonPressed():
	print("i was pressed!")
	for data in outputData:
		var input = outputData[data]["input"]
		if input == "onPressed":
			var targetEntity = world.get_node(outputData[data]["targetEntity"])
			if is_instance_valid(targetEntity):
				var output = outputData[data]["output"]
				var params = outputData[data]["parameters"]
				targetEntity.call(output, params)

func _buttonReleased():
	print("I was released!")
	for data in outputData:
		var input = outputData[data]["input"]
		if input == "onUnpressed":
			var targetEntity = world.get_node(outputData[data]["targetEntity"])
			if is_instance_valid(targetEntity):
				var output = outputData[data]["output"]
				var params = outputData[data]["parameters"]
				targetEntity.call(output, params)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
