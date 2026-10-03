extends Node
class_name InteractableHighlight

@export_group("Target")
@export var target_mesh: MeshInstance3D

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


var _original_materials: Array[Material] = []
var _highlight_materials: Array[StandardMaterial3D] = []

var _tween: Tween
var _is_highlighted: bool = false

func _ready() -> void:
	_setup()


func _setup() -> void:
	if target_mesh == null or target_mesh.mesh == null:
		return

	for i in range(target_mesh.mesh.get_surface_count()):
		var original := target_mesh.get_active_material(i)

		_original_materials.append(
			target_mesh.get_surface_override_material(i)
		)

		if original is StandardMaterial3D:
			var highlight := original.duplicate() as StandardMaterial3D

			highlight.emission_enabled = true
			highlight.emission = highlight_color
			highlight.emission_energy_multiplier = 0.0

			_highlight_materials.append(highlight)
		else:
			_highlight_materials.append(null)

func set_highlight(enabled: bool) -> void:
	if target_mesh == null:
		return

	if _is_highlighted == enabled:
		return

	_is_highlighted = enabled

	if _tween and _tween.is_running():
		_tween.kill()

	if enabled:
		for i in range(_highlight_materials.size()):
			if _highlight_materials[i] != null:
				target_mesh.set_surface_override_material(
					i,
					_highlight_materials[i]
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
	for material in _highlight_materials:
		if material != null:
			material.emission_energy_multiplier = value


func _get_emission() -> float:
	for material in _highlight_materials:
		if material != null:
			return material.emission_energy_multiplier

	return 0.0


func _restore_materials() -> void:
	if _is_highlighted:
		return
