extends Node3D

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_3d: Camera3D = %Camera3D
@onready var snakes: Node3D = $Snakes

var current_snake: Node3D

func _ready() -> void:
	update_current_snake()

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_D):
		camera_pivot.rotate_y(delta)
		update_current_snake()
	elif Input.is_key_pressed(KEY_A):
		camera_pivot.rotate_y(-delta)
		update_current_snake()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_pivot.position.y += event.factor
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_pivot.position.y -= event.factor

func update_current_snake():
	var new_current: Node3D
	
	
	var min_dist := INF
	for snake in snakes.get_children():
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
			current_snake.tree_exited.disconnect(on_snek_ded)
		
		current_snake = new_current
		
		if current_snake:
			current_snake.is_current = true
			current_snake.tree_exited.connect(on_snek_ded)
