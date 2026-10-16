@tool
extends Resource
class_name CircuitPiece

enum CircuitType {
	L_MESH,
	I_MESH,
	T_MESH,
	O_MESH
}

@export var type: CircuitType = CircuitType.I_MESH
@export_enum("0°:0", "90°:90", "-90°:-90", "180°:180")

var rotation: int = 0
