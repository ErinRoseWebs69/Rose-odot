bl_info = {
    "name": "Rose-odot System",
    "blender": (3, 0, 0),
    "category": "Object",
}

import bpy

class RoseodotAddIOOperator(bpy.types.Operator):
    bl_label = "Add I/O"
    bl_idname = "roseodot_system.add_io_operator"
    
    def execute(self, context):
        return

class RoseodotRemoveIOOperator(bpy.types.Operator):
    bl_label = "Remove I/O"
    bl_idname = "roseodot_system.remove_io_operator"
    
    def execute(self, context):
        return

class RoseodotProperties(bpy.types.PropertyGroup):
    originEntity: bpy.props.StringProperty()
    input: bpy.props.StringProperty(name= "Input")
    targetEntity: bpy.props.StringProperty(name= "Target Name")
    output: bpy.props.StringProperty(name= "Output")
    params: bpy.props.StringProperty(name= "Parameters")
    delay: bpy.props.FloatProperty(name= "Enter Delay Amount", soft_min = 0)
    
    io_enum: bpy.props.EnumProperty(
        name= "Input/Output",
        items= [('add', "Add I/O", ""),
                ('remove', "Remove I/O", "")
        ]
    )
    
    #io_list: bpy.types.bpy_prop_array("hi")

class RoseodotPanel(bpy.types.Panel):
    bl_label = "Roseodot Input/Output System"
    bl_idname = "SCENE_PT_layout"
    bl_space_type = 'PROPERTIES'
    bl_region_type = 'WINDOW'
    bl_context = "object"
    bl_options = {'DEFAULT_CLOSED'}
    
    def draw(self, context):
        layout = self.layout
        scene = context.scene
        obj = context.object
        roseodot_tool = scene.roseodot_tool
        
        row = layout.row()
        row.label(text = "NOTE: If object is not in 'io' collection, data will not work")
        
        row = layout.row()
        row.label(text = "Originating Entity:")
        row = layout.row()
        row.prop(roseodot_tool, "originEntity")
        
        row = layout.row()
        row.label(text = "Output:")
        row = layout.row()
        row.prop(roseodot_tool, "input")
        
        row = layout.row()
        row.label(text = "Target Entity:")
        row = layout.row()
        row.prop(roseodot_tool, "targetEntity")
        
        row = layout.row()
        row.label(text = "Input:")
        row = layout.row()
        row.prop(roseodot_tool, "output")
        
        row = layout.row()
        row.label(text = "Parameters:")
        row = layout.row()
        row.prop(roseodot_tool, "params")
        
        row = layout.row()
        row.label(text = "Delay:")
        row = layout.row()
        row.prop(roseodot_tool, "delay")
        
        row = layout.row(align=True)
        row.operator("roseodot_system.add_io_operator")
        row.operator("roseodot_system.remove_io_operator")
        
        #row = layout.row(align=True)
        #row.prop(roseodot_tool, "io_list")

classes = [RoseodotProperties, RoseodotPanel,RoseodotAddIOOperator, RoseodotRemoveIOOperator]

def register():
    for cls in classes:
        bpy.utils.register_class(cls)
        bpy.types.Scene.roseodot_tool = bpy.props.PointerProperty(type= RoseodotProperties)

def unregister():
    for cls in classes:
        bpy.utils.unregister_class(cls)
        del bpy.types.Scene.roseodot_tool

if __name__ == "__main__":
    register