extends Node3D

@onready var curve: Curve3D = $Path3D.curve
@onready var body: CSGPolygon3D = $CSGPolygon3D
@onready var head: MeshInstance3D = $MeshInstance3D

var direction: Vector3 = Vector3.RIGHT
var current_point := 1

func _ready() -> void:
#	Engine.time_scale = 0.1
	curve.set_point_position(current_point, curve.get_point_position(current_point) + direction* 0.01)
	head.position = curve.get_point_position(current_point) + direction * 0.5
	head.rotation.y = get_forward_rotation()

func _process(delta: float) -> void:
	curve.set_point_position(current_point, curve.get_point_position(current_point) + direction * 2 * delta)
#	head.position = head.position.lerp(curve.get_point_position(current_point) + direction * 0.8, 0.01)
	head.position = curve.get_point_position(current_point) + direction * 0.5
	head.rotation.y = lerp_angle(head.rotation.y, get_forward_rotation(), 0.1)
	
	if Input.is_action_just_pressed("ui_left"):
		direction = direction.rotated(Vector3.UP, PI/2)
		curve.add_point(curve.get_point_position(current_point) + direction * delta)
		current_point += 1
	
	if Input.is_action_just_pressed("ui_right"):
		direction = direction.rotated(Vector3.UP, -PI/2)
		curve.add_point(curve.get_point_position(current_point))
		current_point += 1

func get_forward_rotation() -> float:
	if direction.is_equal_approx(Vector3.RIGHT):
		return -PI / 2
	elif direction.is_equal_approx(Vector3.LEFT):
		return PI / 2
	elif direction.is_equal_approx(Vector3.FORWARD):
		return 0
	elif direction.is_equal_approx(Vector3.BACK):
		return PI
	return 0
