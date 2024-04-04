extends MeshInstance3D

class_name tempCube

func _init():
	var shape = BoxMesh.new()
	mesh = shape
	position = Vector3(0,-7,0)
	name = "cube"

func open(params):
	print("open")
	position = Vector3(0,-8,0)

func close(params):
	print("close")
	position = Vector3(0,-7,0)
