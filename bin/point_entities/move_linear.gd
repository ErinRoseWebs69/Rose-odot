extends AnimatableBody3D

class_name move_linear

var moveDistance:float
var interpType:String
var duration:float
var moveAxis:String
var physics
var currentState = "closed"
var startPos:Vector3
var endPos:Vector3

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
	
	moveDistance = entityData["moveDistance"]
	duration = entityData["duration"]
	moveAxis = entityData["moveAxis"]
	
	startPos.x = entityData["position"][0]
	startPos.y = entityData["position"][1]
	startPos.z = entityData["position"][2]
	
	match moveAxis:
		"x":
			endPos = Vector3((startPos.x + moveDistance), startPos.y, startPos.z)
		"y":
			endPos = Vector3(startPos.x, (startPos.y + moveDistance), startPos.z)
		"z":
			endPos = Vector3(startPos.x, startPos.y, (startPos.z + moveDistance))
	
	for i in mi.get_surface_override_material_count():
		if mi.get_active_material(i) != null:
			var mat = mi.get_active_material(i).resource_name
			mi.set_surface_override_material(i, ResourceLoader.load("res://materials/"+mat+".tres"))
	
	if entityData.has("outputs"):
		outputData = entityData["outputs"]

var tween
func open(params):
	_onOpen()
	if tween:
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "global_position", endPos, _moveDuration(endPos)) #prefer _getDistance(endPos) * speed
	tween.connect("finished", _onFullyOpened)

func close(params):
	_onClose()
	if tween:
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "global_position", startPos, _moveDuration(startPos))
	tween.connect("finished", _onFullyClosed)

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

func _moveDuration(movingDistance):
	var currentDist = global_position
	var distanceDif
	
	match moveAxis:
		"x":
			distanceDif = abs(movingDistance.x - currentDist.x)
		"y":
			distanceDif = abs(movingDistance.y - currentDist.y)
		"z":
			distanceDif = abs(movingDistance.z - currentDist.z)
	
	var finalDuration = duration * (distanceDif / abs(moveDistance))
	return finalDuration

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	physics = delta