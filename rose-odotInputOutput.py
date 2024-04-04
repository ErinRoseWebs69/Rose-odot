bl_info = {
    "name": "Rose-odot Input/Output System",
    "blender": (3, 0, 0),
    "category": "Object",
}

import bpy

class RoseOdotInputOutputProperties(bpy.types.PropertyGroup):
    dropdown_text: bpy.props.StringProperty(default="hello")

class OBJECT_PT_RoseOdotInputOutputPanel(bpy.types.Panel):
    bl_label = "Rose-odot Input/Output System"
    # bl_idname = "OBJECT_PT_roseodot_input_output_panel"
    bl_space_type = 'PROPERTIES'
    bl_region_type = 'WINDOW'
    bl_context = "data"
    bl_options = {'DEFAULT_CLOSED'}

    def draw(self, context):
        layout = self.layout
        obj = context.object
        # io_strings = list(obj)
        
        layout.operator("string")
        
        row = layout.row()
        row.prop(obj.vs,"string")

def register():
    bpy.utils.register_class(RoseOdotInputOutputProperties)
    bpy.utils.register_class(OBJECT_PT_RoseOdotInputOutputPanel)

    bpy.types.Object.roseodot_input_output_properties = bpy.props.PointerProperty(type=RoseOdotInputOutputProperties)

def unregister():
    bpy.utils.unregister_class(RoseOdotInputOutputProperties)
    bpy.utils.unregister_class(OBJECT_PT_RoseOdotInputOutputPanel)

    del bpy.types.Object.roseodot_input_output_properties

if __name__ == "__main__":
    register()
