class_name ExcludeInvisibleGLTFDocumentExtension
extends GLTFDocumentExtension


func _convert_scene_node(state: GLTFState, gltf_node: GLTFNode, scene_node: Node) -> void:
	if scene_node.has_method(&"is_visible") and not scene_node.is_visible():
		gltf_node.parent = -2
