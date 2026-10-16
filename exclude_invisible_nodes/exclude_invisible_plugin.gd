@tool
extends EditorPlugin


var exclude_invisible_gltf_doc_ext := ExcludeInvisibleGLTFDocumentExtension.new()


func _enter_tree() -> void:
	GLTFDocument.register_gltf_document_extension(exclude_invisible_gltf_doc_ext)


func _exit_tree() -> void:
	GLTFDocument.unregister_gltf_document_extension(exclude_invisible_gltf_doc_ext)
