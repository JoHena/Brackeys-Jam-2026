extends Node
class_name InteractableHighlight

@export_group("Target")
@export var target_meshes: Array[MeshInstance3D] = []
@export var highlight_surface: int = 0

@export_group("Highlight")
@export var highlight_color: Color = Color(0.99, 0.65, 0.14, 1.0)
@export var glow_intensity: float = 2.5

@export_group("Transition")
@export var fade_in_duration: float = 0.2
@export var fade_out_duration: float = 0.45

@export var fade_in_transition: Tween.TransitionType = Tween.TRANS_CUBIC
@export var fade_out_transition: Tween.TransitionType = Tween.TRANS_SINE

@export var fade_in_ease: Tween.EaseType = Tween.EASE_OUT
@export var fade_out_ease: Tween.EaseType = Tween.EASE_IN_OUT


class HighlightData:
	var mesh: MeshInstance3D
	var surface: int
	var original_material: Material
	var highlight_material: StandardMaterial3D


var _materials: Array[HighlightData] = []

var _tween: Tween
var _is_highlighted := false


func _ready() -> void:
	_setup()


func _setup() -> void:
	_materials.clear()

	for mesh_instance in target_meshes:
		if mesh_instance == null or mesh_instance.mesh == null:
			continue

		if highlight_surface >= mesh_instance.mesh.get_surface_count():
			continue

		var original := mesh_instance.get_active_material(highlight_surface)

		if not original is StandardMaterial3D:
			continue

		var data := HighlightData.new()

		data.mesh = mesh_instance
		data.surface = highlight_surface

		data.original_material = mesh_instance.get_surface_override_material(
			highlight_surface
		)

		data.highlight_material = original.duplicate() as StandardMaterial3D

		data.highlight_material.emission_enabled = true
		data.highlight_material.emission = highlight_color
		data.highlight_material.emission_energy_multiplier = 0.0

		_materials.append(data)


func set_highlight(enabled: bool) -> void:
	if _is_highlighted == enabled:
		return

	_is_highlighted = enabled

	if _tween and _tween.is_running():
		_tween.kill()

	if enabled:
		for data in _materials:
			data.mesh.set_surface_override_material(
				data.surface,
				data.highlight_material
			)

		_tween = create_tween()
		_tween.set_trans(fade_in_transition)
		_tween.set_ease(fade_in_ease)

		_tween.tween_method(
			_set_emission,
			_get_emission(),
			glow_intensity,
			fade_in_duration
		)

	else:
		_tween = create_tween()
		_tween.set_trans(fade_out_transition)
		_tween.set_ease(fade_out_ease)

		_tween.tween_method(
			_set_emission,
			_get_emission(),
			0.0,
			fade_out_duration
		)

		_tween.tween_callback(_restore_materials)


func _set_emission(value: float) -> void:
	for data in _materials:
		data.highlight_material.emission_energy_multiplier = value


func _get_emission() -> float:
	if _materials.is_empty():
		return 0.0

	return _materials[0].highlight_material.emission_energy_multiplier


func _restore_materials() -> void:
	if _is_highlighted:
		return

	for data in _materials:
		data.mesh.set_surface_override_material(
			data.surface,
			data.original_material
		)
