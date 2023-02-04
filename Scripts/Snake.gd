extends Node3D

@onready var curve: Curve3D = $Path3D.curve
@onready var body: CSGPolygon3D = $CSGPolygon3D
@onready var head: MeshInstance3D = $MeshInstance3D
@onready var front_raycast: RayCast3D = $FrontRaycast
@onready var down_raycast: RayCast3D = $BackRaycast
@onready var glow: MeshInstance3D = %MeshInstance3D2
@onready var leaves: GPUParticles3D = $GPUParticles3D

@export var up_direction: Vector3

var is_current: bool:
	set(current):
		is_current = current
		glow.visible = current

var disable_raycasts: int = 60
var down_timeout: float

var direction: Vector3 = Vector3.UP
var head_position: Vector3
var current_point := 1

var μtimer = randf_range(3, 8)

signal deded

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
	head.position = head_position
	leaves.position = head_position
	leaves.look_at(direction)
	
	front_raycast.position = head_position
	front_raycast.target_position = direction * 0.6
	down_raycast.position = head_position - direction * 0.2
	down_raycast.target_position = -up_direction * 0.6
	
	if disable_raycasts > 0:
		disable_raycasts -= 1
		return
	
	if front_raycast.is_colliding():
		if front_raycast.get_collider().get_meta(&"snek", false):
			set_physics_process(false)
			glow.hide()
			deded.emit()
			leaves.emitting = false
			return
		
		var prev := direction
		rotate_to(up_direction)
		up_direction = -prev
		disable_raycasts = 30
	
	if not down_raycast.is_colliding():
		down_timeout += delta
		
		if down_timeout >= 0.05:
			var prev := direction
			rotate_to(-up_direction)
			up_direction = prev
			disable_raycasts = 30
	else:
		down_timeout = 0
	
	μtimer -= delta
	if μtimer <= 0:
		μtimer = randf_range(3, 8)
		var μsnake = load("res://Scenes/MicroSnake.tscn").instantiate()
		μsnake.position = global_position + head_position
		μsnake.direction = direction.rotated(up_direction, PI/2)
		μsnake.up_direction = up_direction
		owner.add_child(μsnake)

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
	curve.set_point_position(current_point, head_position - direction * 0.5)
	curve.add_point((head_position - direction * 0.5).lerp(head_position + dir * 0.5, 0.5))
	direction = dir
	curve.add_point(head_position + direction * 0.5)
	curve.add_point(head_position + direction * 0.51)
	current_point = curve.point_count - 1
	head_position = curve.get_point_position(current_point)

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
