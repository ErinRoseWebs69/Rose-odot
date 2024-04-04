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
            if geo_collection:
                for room_collection in geo_collection.children:
                    room_name = room_collection.name
                    room_data = {}
                    for room_obj in room_collection.objects:
                        if room_obj.type == 'MESH':
                            mesh_data = room_obj.data
                            bm = bmesh.new()
                            bm.from_mesh(mesh_data)
                            bmesh.ops.triangulate(bm, faces=bm.faces)
                            bm.to_mesh(mesh_data)
                            bm.free()
                            
                            # Create a dictionary to store triangle data for each material index
                            material_triangles = {}

                            # Iterate over each triangle in the mesh
                            for poly in mesh_data.polygons:
                                if len(poly.vertices) == 3:  # Check if the polygon is a triangle
                                    # Get the material applied to the face
                                    material_index = min(poly.material_index, len(mesh_data.materials) - 1)
                                    if material_index >= 0:
                                        material_name = mesh_data.materials[material_index].name
                                    else:
                                        material_name = "DefaultMaterial"

                                    # Get the vertices of the triangle and swap Y and Z coordinates
                                    vertices = [room_obj.matrix_world @ mesh_data.vertices[i].co for i in poly.vertices]
                                    vertices = [[v[0], v[1], v[2]] for v in vertices]  # Swap Y and Z coordinates
                                    
                                    uv_layer = mesh_data.uv_layers.active.data
                                    uv_coords = []
                                    for loop_index in poly.loop_indices:
                                        uv_coords.append([uv_layer[loop_index].uv[0], uv_layer[loop_index].uv[1]])  # Extract UV coordinates and convert to Vector2 format
                                    
                                    # Create JSON data for the triangle
                                    tri_data = {
                                        "vertices": vertices,
                                        "uv_coords": uv_coords, # Add UV coordinates to the JSON data
                                        "material": material_name
                                    }

                                # Add triangle data to the dictionary for the material index
                                if material_index not in material_triangles:
                                    material_triangles[material_index] = []
                                material_triangles[material_index].append(tri_data)
                                
                            # Add the material triangles to the room data
                            for material_index, triangles in material_triangles.items():
                                if room_name not in json_data["geo"]:
                                    json_data["geo"][room_name] = {}  # Add the room name if it doesn't exist
                                json_data["geo"][room_name].update({f"{material_index}": triangles})
                            
                            #for material_index, faces in material_triangles.items():
                            #        if material_index not in room_data:
                            #            room_data[material_index] = {}
                            #        room_data[material_index].update({f"face{i}": face_data for i, face_data in enumerate(faces)})
                            #json_data["geo"][room_name] = room_data
            
            # Export objects in the "entities" collection
            entities_collection = map_collection.children.get("entities")
            if entities_collection:
                for obj in entities_collection.objects:
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
