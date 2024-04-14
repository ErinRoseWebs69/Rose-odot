bl_info = {
    "name": "Export Map to JSON",
    "blender": (3, 3, 1),
    "category": "Import-Export",
}

import bpy
import json
import math
import bmesh

class ExportMapToJSON(bpy.types.Operator):
    bl_idname = "export.map_to_json"
    bl_label = "Export Map to JSON"

    filepath: bpy.props.StringProperty(subtype="FILE_PATH")

    def execute(self, context):
        # Check if the "map" collection exists
        map_collection = bpy.data.collections.get("map")
        if map_collection:
            # Create a dictionary to store JSON data
            # Create a dictionary to store JSON data
            json_data = {
                "world": {},
                "geo": {},
                "point_entities": {}
            }

            # Export objects in the "geo" collection
            geo_collection = map_collection.children.get("geo")
            map_name = geo_collection.children.get("geo").name
            if geo_collection:
                
                for obj in geo_collection.objects:
                    obj_info = [map_name + "/" + obj.name + ".obj"]
                    if obj_info not in json_data["geo"]:
                        json_data["geo"] = obj_info
            
            # Export objects in the "entities" collection
            entities_collection = map_collection.children.get("entities")
            if entities_collection:
                for obj in entities_collection.objects:
                    
                    io_modifier = None
                    for modifiers in obj.modifiers:
                        if modifier.type == 'NODES' and modifier.node_group is not None:
                            io_modifier = modifier
                            break
                
                    if obj.type == 'LIGHT' and obj.data.type == 'POINT':
                        light_data = obj.data
                        light_color = light_data.color
                        position = obj.location

                        # Add point light data to the point_entities section
                        json_data["point_entities"][obj.name] = {
                            "type": "light",
                            "name": obj.name,
                            "range": light_data.distance,
                            "attenuation": 1.0,
                            "color": [light_color[0], light_color[1], light_color[2]],
                            "energy": light_data.energy,
                            "position": [position.x, position.y, position.z],
                            "shadows": light_data.use_shadow
                        }
                    
                    # Export player_start
                    elif obj.type == 'EMPTY' and obj.name == "player_start":
                        position = obj.location
                        rotation = obj.rotation_euler
                        
                        # Add player_start data to the point_entities section
                        json_data["point_entities"][obj.name] = {
                            "type": "player_start",
                            "position": [position.x, position.z, -(position.y)],
                            "rotation": [math.degrees(rotation.x), math.degrees(rotation.y), math.degrees(rotation.z)]
                        }
                    
                    elif obj.type == 'MESH':
                        entityType = obj.data.get("entityType")
                        if entityType == "trigger_multiple":
                            position = obj.position
                            
                            min_corner, max_corner = obj.bound_box[0], obj.bound_box[6]
                            size_x = max_corner[0] - min_corner[0]
                            size_y = max_corner[1] - min_corner[1]
                            size_z = max_corner[2] - min_corner[2]
                            
                            size = [size_x, size_y, size_z]
                            
                            if io_modifier:
                                input_data = io_modifier.node_group.inputs
                                for input_socket in 
                            
                            json_data["point_entities"][obj.name] = {
                                "type": "trigger_multiple",
                                "name": obj.name,
                                "position": position,
                                "size": size,
                                "outputs": outputs
                            }
                            

            # Write JSON data to file
            with open(self.filepath, 'w') as file:
                json.dump(json_data, file, indent=4)

            return {'FINISHED'}
        else:
            self.report({'ERROR'}, "The 'map' collection does not exist")
            return {'CANCELLED'}

    def invoke(self, context, event):
        wm = context.window_manager
        wm.fileselect_add(self)
        return {'RUNNING_MODAL'}

def menu_func_export(self, context):
    self.layout.operator(ExportMapToJSON.bl_idname, text="Export Map to JSON")

def register():
    bpy.utils.register_class(ExportMapToJSON)
    bpy.types.TOPBAR_MT_file_export.append(menu_func_export)

def unregister():
    bpy.utils.unregister_class(ExportMapToJSON)
    bpy.types.TOPBAR_MT_file_export.remove(menu_func_export)

if __name__ == "__main__":
    register()
