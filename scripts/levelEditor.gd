extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_plane_tool_pressed():
	var mi = editor_plane.new()
	add_child(mi)

func _on_face_edit_tool_pressed():
	pass # Replace with function body.

func _on_decal_tool_pressed():
	pass # Replace with function body.

func _on_entity_tool_pressed():
	pass # Replace with function body.
