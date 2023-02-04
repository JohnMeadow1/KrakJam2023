extends Node3D

@onready var curve: Curve3D = $Path3D.curve
@onready var body: CSGPolygon3D = $CSGPolygon3D
@onready var head: MeshInstance3D = $MeshInstance3D
@onready var ray_cast: RayCast3D = $RayCast3D

@export var up_direction: Vector3

var is_current: bool

var direction: Vector3 = Vector3.UP
var head_position: Vector3
var current_point := 1

func _ready() -> void:
	head_position = direction * 0.01
	curve = curve.duplicate()
	$Path3D.curve = curve
	curve.set_point_position(current_point, head_position)
	head.position = curve.get_point_position(current_point) + direction * 0.5
	head.rotation.y = get_forward_rotation()

func _physics_process(delta: float) -> void:
	head_position += direction * 2 * delta
	curve.set_point_position(current_point, head_position)
#	head.position = head.position.lerp(curve.get_point_position(current_point) + direction * 0.8, 0.01)
	head.position = head_position
	
	if not body.get_meshes().is_empty():
		body.set_instance_shader_parameter("vertex_count",(body.get_meshes()[1].get_faces().size()-18)/24)
	
	ray_cast.position = head_position
	ray_cast.target_position = direction
	
	if ray_cast.is_colliding():
		rotate_to(Vector3.UP)

func _process(delta: float) -> void:
	if not is_current:
		return
	
	if Input.is_action_just_pressed(&"ui_left"):
		rotate_head(PI/2)
	
	if Input.is_action_just_pressed(&"ui_right"):
		rotate_head(-PI/2)

func rotate_head(angle: float):
	rotate_to(direction.rotated(up_direction, angle))

func rotate_to(dir: Vector3):
	direction = dir
	curve.add_point(head_position + direction * 0.01)
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
