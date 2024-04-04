extends CSGBox3D

class_name editor_plane

var mdt = MeshDataTool.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _init():
	for i in mdt.get_vertex_count():
		var point = MeshInstance3D.new()
		var pointShape = SphereMesh.new()
		pointShape.radius = 0.1
		pointShape.height = pointShape.radius * 2
		point.mesh = pointShape
		point.position = mdt.get_vertex(i)
		print(mdt.get_vertex(i))
		add_child(point)
		
