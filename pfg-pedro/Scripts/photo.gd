extends Control
class_name Photo

signal photo_clicked(photo: Photo)

var photo_id: int = 0
@export var file_prefix: String = "res://Assets/Photos/photo"
@export var file_extension: String = ".png"

var selected: bool = false:
	set(value):
		selected = value
		_update_border()

@export var accent_color: Color = Color(1.0, 0.8, 0.3, 1.0)
@export var hover_alpha: float = 0.4
@export var border_width: int = 4

var photo_texture: Texture2D
var is_hovering: bool = false

@onready var photo_button: Button = $PhotoButton
@onready var photo_image: TextureRect = $PhotoButton/PhotoImage
@onready var border: Panel = $PhotoButton/ReactiveBorder


func _ready() -> void:
	photo_button.pressed.connect(_on_pressed)
	photo_button.mouse_entered.connect(_on_mouse_entered)
	photo_button.mouse_exited.connect(_on_mouse_exited)

	load_texture_from_id()
	update_visual()
	_update_border()

	call_deferred("_fit_button_to_image")


func setup(new_photo_id: int) -> void:
	photo_id = new_photo_id

	load_texture_from_id()
	update_visual()

	call_deferred("_fit_button_to_image")


func load_texture_from_id() -> void:
	var path := file_prefix + str(photo_id) + file_extension

	if ResourceLoader.exists(path):
		photo_texture = load(path) as Texture2D
	else:
		push_warning("Imagem não encontrada: " + path)
		photo_texture = null


func update_visual() -> void:
	photo_image.texture = photo_texture


func set_selected(value: bool) -> void:
	selected = value


func _fit_button_to_image() -> void:
	var available_size: Vector2 = size
	var image_size: Vector2 = photo_texture.get_size()

	if available_size.x <= 0 or available_size.y <= 0:
		return

	if image_size.x <= 0 or image_size.y <= 0:
		return

	var scale_x: float = available_size.x / image_size.x
	var scale_y: float = available_size.y / image_size.y
	var scale_factor: float = min(scale_x, scale_y)

	var final_size: Vector2 = image_size * scale_factor

	photo_button.size = final_size
	photo_button.position = (available_size - final_size) / 2


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		_fit_button_to_image()


func _on_pressed() -> void:
	photo_clicked.emit(self)
	
	var state_text := "selecionada" if selected else "não selecionada"
	
	photo_button.accessibility_name = "Foto %d" % photo_id
	photo_button.accessibility_description = "Foto %d, %s. Pressione para selecionar esta foto e trocar sua posição com outra." % [photo_id, state_text]


func _on_mouse_entered() -> void:
	is_hovering = true
	_update_border()


func _on_mouse_exited() -> void:
	is_hovering = false
	_update_border()


func _update_border() -> void:
	if border == null:
		return

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)

	if selected:
		style.border_color = accent_color
		style.set_border_width_all(border_width)
		border.visible = true
	elif is_hovering:
		var hover_color := accent_color
		hover_color.a = hover_alpha
		style.border_color = hover_color
		style.set_border_width_all(border_width)
		border.visible = true
	else:
		border.visible = false

	border.add_theme_stylebox_override("panel", style)
