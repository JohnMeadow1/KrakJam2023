extends Node3D

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_3d: Camera3D = %Camera3D
@onready var snakes: Node3D = $Snakes

var current_snake: Node3D
var camera_height_direction = 0.0
var camera_height_factor = 0.0
var camera_orbit_direction = 0.0
var camera_orbit_factor = 0.0

func _ready() -> void:
	update_current_snake()

func _process(delta: float) -> void:

	camera_handle_orbit(delta)
	camera_handle_height(delta)

func camera_handle_orbit(delta: float):
	camera_orbit_direction = 0.0
	if Input.is_key_pressed(KEY_D):
		camera_orbit_direction += delta * 3
	if Input.is_key_pressed(KEY_A):
		camera_orbit_direction -= delta * 3
	camera_orbit_factor = lerp(camera_orbit_factor, camera_orbit_direction, 0.2)
	
	if camera_orbit_direction == 0.0 and abs(camera_orbit_factor)<0.001:
		camera_orbit_factor = 0.0
	else:
		camera_pivot.rotate_y(camera_orbit_factor)
		update_current_snake()

func camera_handle_height(delta: float):
	camera_height_direction = 0.0
	if Input.is_key_pressed(KEY_W):
		camera_height_direction += delta * 30.0
	if Input.is_key_pressed(KEY_S):
		camera_height_direction -= delta * 30.0
	camera_height_factor = lerp(camera_height_factor, camera_height_direction,0.2)
	
	if camera_height_direction == 0 and abs(camera_height_factor)<0.01:
		camera_height_factor = 0.0
	else:
		if camera_height_factor > 0:
			camera_pivot.position.y += camera_height_factor
			update_current_snake()
		elif camera_pivot.position.y > 1:
			camera_pivot.position.y += camera_height_factor
			update_current_snake()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_pivot.position.y += event.factor
			update_current_snake()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN or event.button_index == KEY_S:
			camera_pivot.position.y -= event.factor
			update_current_snake()
			

func update_current_snake():
	var new_current: Node3D
	
	var min_dist := INF
	for snake in snakes.get_children():
		if not snake.is_physics_processing():
			continue
		
		var dist = snake.global_position.distance_squared_to(camera_3d.global_position)
		if dist < min_dist:
			new_current = snake
			min_dist = dist
	
	var on_snek_ded = func():
		current_snake = null
		update_current_snake()
	
	if new_current != current_snake:
		if current_snake:
			current_snake.is_current = false
			current_snake.deded.disconnect(on_snek_ded)
		
		current_snake = new_current
		
		if current_snake:
			current_snake.is_current = true
			current_snake.deded.connect(on_snek_ded)
