extends Node3D

@onready var curve: Curve3D = $Path3D.curve
@onready var body: CSGPolygon3D = $CSGPolygon3D
@onready var head: MeshInstance3D = $MeshInstance3D
@onready var glow: MeshInstance3D = %MeshInstance3D2
@onready var leaves: GPUParticles3D = $GPUParticles3D
@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D

@onready var front_raycast: RayCast3D = $FrontRaycast
@onready var down_raycast: RayCast3D = $BackRaycast
@onready var down_raycast2: RayCast3D = down_raycast.duplicate()

@export var up_direction: Vector3

var is_current: bool:
	set(current):
		is_current = current
		glow.visible = current

var disable_raycasts: int = 60
var down_timeout: float

var growth_speed := 0.75

var direction: Vector3 = Vector3.UP
var head_position: Vector3
var current_point := 1

var μtimer = randf_range(2, 4)

signal deded

func _ready() -> void:
	add_child(down_raycast2)
	head_position = direction * 0.01
	curve = curve.duplicate()
	$Path3D.curve = curve
	curve.set_point_position(current_point, head_position)
	head.position = curve.get_point_position(current_point) + direction * 0.5
	head.rotation.y = get_forward_rotation()
	audio.play(randf() * audio.stream.get_length())
	body.material_override = body.material_override.duplicate()

func _physics_process(delta: float) -> void:
	if is_current:
		head_position += direction * growth_speed * delta * 2.0
	else:
		head_position += direction * growth_speed * delta
	curve.set_point_position(current_point, head_position)
	head.position = head_position
	audio.position = head_position
	leaves.position = head_position
	leaves.look_at(leaves.global_position + direction, up_direction)
	
	front_raycast.position = head_position
	front_raycast.target_position = direction * 0.4
	down_raycast.position = head_position - direction * 0.5
	down_raycast.target_position = -up_direction * 0.6
	down_raycast2.position = head_position + direction * 0.5
	down_raycast2.target_position = -up_direction * 0.6
	
	if not body.get_meshes().is_empty():
		body.material_override.set_shader_parameter(&"total_vertices",(body.get_meshes()[1].get_faces().size()*3))
		
	if disable_raycasts > 0:
		disable_raycasts -= 1
		return
	
	if front_raycast.is_colliding():
		if front_raycast.get_collider().get_meta(&"snek", false):
			set_physics_process(false)
			set_process(false)
			glow.hide()
			deded.emit()
			audio.stop()
			leaves.emitting = false
			return
		
		var prev := direction
		rotate_to(up_direction)
		up_direction = -prev
		disable_raycasts = 30
	
	if not down_raycast.is_colliding() and not down_raycast2.is_colliding():
		head_position -= direction * 0.05
		var prev := direction
		rotate_to(-up_direction)
		up_direction = prev
		disable_raycasts = 30
	
	μtimer -= delta
	if μtimer <= 0:
		μtimer = randf_range(2, 4)
		var μsnake = load("res://Scenes/MicroSnake.tscn").instantiate()
		μsnake.position = global_position + head_position
		
		μsnake.direction = direction.rotated(up_direction, PI/2 * (randi()%2*2+1))
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
