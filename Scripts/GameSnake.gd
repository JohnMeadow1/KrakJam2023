extends Node3D

var SNEKOUNT = 10
const MAXNEKS_AT_ONCE = 3

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_3d: Camera3D = %Camera3D
@onready var snakes: Node3D = $Snakes
@onready var snek_spawners: Node3D = $SnekSpawners

@onready var total: Label = %Total

var current_snake: Node3D
var camera_height_direction = 0.0
var camera_height_factor = 0.0
var camera_orbit_direction = 0.0
var camera_orbit_factor = 0.0

var mouse_orbit_direction = 0.0
var mouse_height_direction = 0.0
var mouse_LMB_pressed = false
var mouse_RMB_pressed = false
var mouse_MMB_pressed = false

var sneqs_alive: int

func _ready() -> void:
	snakes.child_entered_tree.connect(func(sn):
		sneqs_alive += 1
		sn.owner = self
		
		sn.deded.connect(func():
			sneqs_alive -= 1
			if sneqs_alive < MAXNEKS_AT_ONCE:
				make_sneak()
			
			if sn == current_snake:
				current_snake = null
				update_current_snake()
		)
	)
	
	for i in MAXNEKS_AT_ONCE:
		make_sneak()
	
	update_current_snake()

func make_sneak():
	for i in 1000:
		if snek_spawners.get_child(randi() % snek_spawners.get_child_count()).spawn_snek():
			SNEKOUNT -= 1
			break

func _process(delta: float) -> void:
	camera_handle_orbit(delta)
	camera_handle_height(delta)

func camera_handle_orbit(delta: float):
	camera_orbit_direction = 0.0
	if Input.is_key_pressed(KEY_D):
		camera_orbit_direction += delta * 3
	if Input.is_key_pressed(KEY_A):
		camera_orbit_direction -= delta * 3
	camera_orbit_factor = lerp(camera_orbit_factor, camera_orbit_direction + mouse_orbit_direction, 0.2)
	mouse_orbit_direction = 0.0
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
	camera_height_factor = lerp(camera_height_factor, camera_height_direction + mouse_height_direction,0.2)
	mouse_height_direction = 0.0
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
	if event is InputEventMouseMotion:
		if mouse_MMB_pressed:
			mouse_orbit_direction -= event.relative.x * 0.001
			mouse_height_direction -= event.relative.y * 0.0314159
		if mouse_RMB_pressed:
			camera_pivot.position -= Vector3(event.relative.x, 0, event.relative.y).rotated(Vector3.UP,camera_pivot.rotation.y) *0.01

	if event is InputEventMouseButton:
		if event.pressed: 
			if event.button_index == MOUSE_BUTTON_LEFT:
				mouse_LMB_pressed = true
			if event.button_index == MOUSE_BUTTON_RIGHT:
				mouse_RMB_pressed = true
			if event.button_index == MOUSE_BUTTON_MIDDLE:
				mouse_MMB_pressed = true
			Input.set_mouse_mode( Input.MOUSE_MODE_CAPTURED )

		else:
			if event.button_index == MOUSE_BUTTON_LEFT:
				mouse_LMB_pressed = false
			if event.button_index == MOUSE_BUTTON_RIGHT:
				mouse_RMB_pressed = false
			if event.button_index == MOUSE_BUTTON_MIDDLE:
				mouse_MMB_pressed = false
			Input.set_mouse_mode( Input.MOUSE_MODE_VISIBLE )

		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			mouse_height_direction += 2

		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			mouse_height_direction -= 2

#	if event is InputEventMouseButton:
#		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
#			camera_pivot.position.y += event.factor
#			update_current_snake()
#		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN or event.button_index == KEY_S:
#			camera_pivot.position.y -= event.factor
#			update_current_snake()
			

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
	
	if new_current != current_snake:
		if current_snake:
			current_snake.is_current = false
		
		current_snake = new_current
		
		if current_snake:
			current_snake.is_current = true

func update_score() -> void:
	total.text = "%0.2fm" % snakes.get_children().reduce(func(value, snek): return value + snek.curve.get_baked_length(), 0.0)
