class_name Player
extends CharacterBody3D

@export var speed: float = 2.0
@export var sensitivity: float = 0.0036

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _look_delta: Vector2 = Vector2.ZERO
var mouse_lock: bool = true

@onready var camera_3d: Camera3D = $Camera3D
@onready var step_cast: ShapeCast3D = $StepCast


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_look_delta = event.relative


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_lock = true


func _process(_delta: float) -> void:
	if mouse_lock and Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		mouse_lock = not mouse_lock
	elif not mouse_lock and Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		mouse_lock = not mouse_lock


func _physics_process(delta: float) -> void:
	handle_rotation()
	handle_gravity(delta)
	handle_movement(delta)


func handle_rotation() -> void:
	rotate_y(-_look_delta.x * sensitivity)
	camera_3d.rotate_x(-_look_delta.y * sensitivity)
	camera_3d.rotation.x = clamp(
		camera_3d.rotation.x,
		deg_to_rad(-80),
		deg_to_rad(85)
	)
	_look_delta = Vector2.ZERO


func handle_movement(delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector(
		"strafe_left",
		"strafe_right",
		"walk_forward",
		"walk_backward",
	)
	var direction: Vector3 = (
		transform.basis * Vector3(input_dir.x, 0, input_dir.y)
	).normalized()

	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = lerp(velocity.x, 0.0, delta * 6)
		velocity.z = lerp(velocity.z, 0.0, delta * 6)

	move_and_slide()


func handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta
