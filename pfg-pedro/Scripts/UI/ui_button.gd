extends Control
class_name UIButton

signal pressed

@export var icon: Texture2D

var disabled: bool = false:
	set(value):
		disabled = value
		if is_node_ready():
			_update_disabled_state()

@export var normal_color: Color = Color.WHITE
@export var hover_color: Color = Color(1.0, 0.8, 0.3, 1.0)
@export var pressed_color: Color = Color(0.9, 0.6, 0.1, 1.0)
@export var disabled_color: Color = Color(1, 1, 1, 0.3)

@export var shadow_alpha: float = 0.35
@export var shadow_blur: float = 4.0
@export var shadow_offset_x: float = 4.0
@export var shadow_offset_y: float = 4.0

@onready var shadow: TextureRect = $Shadow
@onready var button: TextureButton = $Button

const SHADOW_SHADER: Shader = preload("res://Shaders/button_shadow.gdshader")

var is_button_down: bool = false


func _ready() -> void:
	button.texture_normal = icon

	shadow.texture = icon
	shadow.modulate = Color.WHITE

	var material := ShaderMaterial.new()
	material.shader = SHADOW_SHADER
	shadow.material = material

	button.mouse_entered.connect(_on_mouse_entered)
	button.mouse_exited.connect(_on_mouse_exited)
	button.button_down.connect(_on_button_down)
	button.button_up.connect(_on_button_up)
	button.pressed.connect(_on_pressed)

	_update_layout()
	_update_disabled_state()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		_update_layout()


func _update_layout() -> void:
	button.size = size

	if is_button_down:
		button.position = Vector2(shadow_offset_x, shadow_offset_y)
	else:
		button.position = Vector2.ZERO

	var padding: float = shadow_blur * 3.0
	var shadow_size: Vector2 = size + Vector2(padding * 2.0, padding * 2.0)

	shadow.position = Vector2(shadow_offset_x, shadow_offset_y) - Vector2(padding, padding)
	shadow.size = shadow_size

	var material: ShaderMaterial = shadow.material as ShaderMaterial
	if material == null:
		return

	material.set_shader_parameter("shadow_texture", icon)
	material.set_shader_parameter("shadow_alpha", shadow_alpha)
	material.set_shader_parameter("blur_uv", Vector2(shadow_blur / shadow_size.x, shadow_blur / shadow_size.y))
	material.set_shader_parameter("inner_min", Vector2(padding / shadow_size.x, padding / shadow_size.y))
	material.set_shader_parameter("inner_size", Vector2(size.x / shadow_size.x, size.y / shadow_size.y))


func _on_pressed() -> void:
	if disabled:
		return

	pressed.emit()


func _on_mouse_entered() -> void:
	if disabled:
		return

	button.modulate = hover_color


func _on_mouse_exited() -> void:
	_update_color()


func _on_button_down() -> void:
	if disabled:
		return

	is_button_down = true
	button.position = Vector2(shadow_offset_x, shadow_offset_y)
	button.modulate = pressed_color
	shadow.visible = false


func _on_button_up() -> void:
	if disabled:
		return

	is_button_down = false
	button.position = Vector2.ZERO
	button.modulate = hover_color
	shadow.visible = true


func _update_disabled_state() -> void:
	button.disabled = disabled
	button.visible = not disabled
	shadow.visible = not disabled and not is_button_down

	if disabled:
		is_button_down = false
		button.position = Vector2.ZERO
		return

	_update_color()


func _update_color() -> void:
	if not is_node_ready():
		return

	if disabled:
		return

	button.modulate = normal_color
	shadow.visible = not is_button_down
