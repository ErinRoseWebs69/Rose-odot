extends OmniLight3D

class_name light

#var targetName:String
#var range:float
#var attenuation:float
#var color:Array
#var energy:float
#var position:Array
#var shadows:bool
#var _editorModel:String

var validInputs = [
	"turnOn",
	"turnOff"
]

#@onready var world = $world

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _init(entityData, world):
	name = entityData["name"]
	omni_range = entityData["range"]
	omni_attenuation = entityData["attenuation"]
	light_color.r = entityData["color"][0]
	light_color.g = entityData["color"][1]
	light_color.b = entityData["color"][2]
	light_energy = entityData["energy"]
	position.x = entityData["position"][0]
	position.y = entityData["position"][1]
	position.z = entityData["position"][2]
	shadow_enabled = entityData["shadows"]

#func getInput(output, params):
	#if validInputs.has(output):
		#match output:
			#"turnOff":
				#turnOff()
			#"turnOn":
				#turnOn()
	#else:
		#print("Unknown input on " + name)

func inputType(type, outputs, params):
	pass

func turnOff(params):
	visible = false

func turnOn(params):
	visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
