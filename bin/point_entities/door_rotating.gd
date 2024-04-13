extends AnimatableBody3D

class_name door_rotating

var rotateDegrees:float
var interpType:String
var duration:float
var rotateAxis:String
var currentState = "closed"
var startAngle:Vector3
var endAngle:Vector3

var outputData
var world

#var tween = self.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _init(entityData, worldNode):
	world = worldNode
	
	var mi = MeshInstance3D.new()
	name = entityData["name"]
	mi.mesh = ResourceLoader.load("res://models/"+entityData["model"])
	mi.name = "collision"
	self.add_child(mi)
	
	if entityData["collisions"] == true:
		mi.create_trimesh_collision()
		var staticbody = mi.get_child(0)
		var col = CollisionShape3D.new()
		col.shape = staticbody.get_child(0).shape
		self.add_child(col)
		mi.get_child(0).queue_free()
	
	position.x = entityData["position"][0]
	position.y = entityData["position"][1]
	position.z = entityData["position"][2]
	
	rotation_degrees.x = entityData["rotation"][0]
	rotation_degrees.y = entityData["rotation"][1]
	rotation_degrees.z = entityData["rotation"][2]
	
	rotateDegrees = entityData["rotationDegrees"]
	duration = entityData["duration"]
	rotateAxis = entityData["rotationAxis"]
	
	startAngle.x = entityData["rotation"][0]
	startAngle.y = entityData["rotation"][1]
	startAngle.z = entityData["rotation"][2]
	
	match rotateAxis:
		"x":
			endAngle = Vector3((startAngle.x + rotateDegrees), startAngle.y, startAngle.z)
		"y":
			endAngle = Vector3(startAngle.x, (startAngle.y + rotateDegrees), startAngle.z)
		"z":
			endAngle = Vector3(startAngle.x, startAngle.y, (startAngle.z + rotateDegrees))
	
	if entityData.has("outputs"):
		outputData = entityData["outputs"]
var tween
func open(params):
	_onOpen()
	if tween:
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	currentState = "opening"
	tween.tween_property(self, "global_rotation_degrees", endAngle, _rotateDuration(endAngle)) #prefer _getDistance(endPos) * speed
	tween.connect("finished", _onFullyOpened)

func close(params):
	_onClose()
	if tween:
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	currentState = "closing"
	tween.tween_property(self, "global_rotation_degrees", startAngle, _rotateDuration(startAngle))
	tween.connect("finished", _onFullyClosed)

func toggleState(params):
	if currentState == "closed" or "closing":
		print(currentState)
		open(params)
	elif currentState == "open" or "opening":
		print(currentState)
		close(params)

### Internal Functions
func _onFullyOpened():
	currentState = "opened"
	if not outputData == null:
		for data in outputData:
			var input = outputData[data]["input"]
			if input == "onFullyOpened":
				var targetEntity = world.get_node(outputData[data]["targetEntity"])
				if is_instance_valid(targetEntity):
					var output = outputData[data]["output"]
					var params = outputData[data]["parameters"]
					targetEntity.call(output, params)

func _onFullyClosed():
	currentState = "closed"
	if not outputData == null:
		for data in outputData:
			var input = outputData[data]["input"]
			if input == "onFullyClosed":
				var targetEntity = world.get_node(outputData[data]["targetEntity"])
				if is_instance_valid(targetEntity):
					var output = outputData[data]["output"]
					var params = outputData[data]["parameters"]
					targetEntity.call(output, params)

func _onOpen():
	if not outputData == null:
		for data in outputData:
			var input = outputData[data]["input"]
			if input == "onOpen":
				var targetEntity = world.get_node(outputData[data]["targetEntity"])
				if is_instance_valid(targetEntity):
					var output = outputData[data]["output"]
					var params = outputData[data]["parameters"]
					targetEntity.call(output, params)

func _onClose():
	if not outputData == null:
		for data in outputData:
			var input = outputData[data]["input"]
			if input == "onClose":
				var targetEntity = world.get_node(outputData[data]["targetEntity"])
				if is_instance_valid(targetEntity):
					var output = outputData[data]["output"]
					var params = outputData[data]["parameters"]
					targetEntity.call(output, params)
	
func _rotateDuration(moveAngle):
	var currentRot = global_rotation_degrees
	var angleDif
	
	match rotateAxis:
		"x":
			angleDif = abs(moveAngle.x - currentRot.x)
		"y":
			angleDif = abs(moveAngle.y - currentRot.y)
		"z":
			angleDif = abs(moveAngle.z - currentRot.z)
	
	var finalDuration = duration * (angleDif / rotateDegrees)
	return finalDuration

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
