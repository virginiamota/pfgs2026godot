extends Control
class_name PhotoPiece

signal drag_started(piece)
signal drag_released(piece)

@export var piece_id: int = 1:
	set(value):
		piece_id = value
		if is_node_ready():
			_update_image()

@export var correct_slot_id: int = 0

@export var piece_texture: Texture2D
@export var image_prefix: String = "res://Assets/PhotoPieces/photopiece"
@export var image_extension: String = ".png"

@export var drag_z_index: int = 100
@export var move_duration: float = 0.12

@export var locked: bool = false:
	set(value):
		locked = value
		if is_node_ready():
			_update_locked_state()

var current_slot: Control = null

var start_global_position: Vector2
var previous_global_position: Vector2

var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

var _original_z_index: int = 0
var _move_tween: Tween = null

@onready var photo_image: TextureRect = $PieceImage


func _ready() -> void:
	if correct_slot_id <= 0:
		correct_slot_id = piece_id

	mouse_filter = Control.MOUSE_FILTER_STOP

	if photo_image != null:
		photo_image.mouse_filter = Control.MOUSE_FILTER_IGNORE

	start_global_position = global_position
	previous_global_position = global_position

	_update_image()
	_update_locked_state()

	set_process(false)


func _gui_input(event: InputEvent) -> void:
	if locked:
		return

	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton

		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_start_drag()
			accept_event()


func _input(event: InputEvent) -> void:
	if not dragging:
		return

	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton

		if mouse_event.button_index == MOUSE_BUTTON_LEFT and not mouse_event.pressed:
			_finish_drag()
			get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position() - drag_offset


func _start_drag() -> void:
	if dragging:
		return

	if _move_tween != null:
		_move_tween.kill()
		_move_tween = null

	dragging = true
	previous_global_position = global_position
	drag_offset = get_global_mouse_position() - global_position

	_original_z_index = z_index
	z_index = drag_z_index

	var parent := get_parent()
	if parent != null:
		parent.move_child(self, parent.get_child_count() - 1)

	set_process(true)

	drag_started.emit(self)


func _finish_drag() -> void:
	if not dragging:
		return

	dragging = false
	set_process(false)

	z_index = _original_z_index

	drag_released.emit(self)


func snap_to_slot(slot: Control, animated: bool = true) -> void:
	current_slot = slot

	var target_position := slot.global_position + ((slot.size - size) * 0.5)
	move_to_global_position(target_position, animated)


func move_to_global_position(target_position: Vector2, animated: bool = true) -> void:
	if _move_tween != null:
		_move_tween.kill()
		_move_tween = null

	if not animated or move_duration <= 0.0:
		global_position = target_position
		return

	_move_tween = create_tween()
	_move_tween.set_trans(Tween.TRANS_SINE)
	_move_tween.set_ease(Tween.EASE_OUT)
	_move_tween.tween_property(
		self,
		"global_position",
		target_position,
		move_duration
	)


func return_to_previous_position(animated: bool = true) -> void:
	current_slot = null
	move_to_global_position(previous_global_position, animated)


func return_to_start_position(animated: bool = true) -> void:
	current_slot = null
	move_to_global_position(start_global_position, animated)


func save_current_position_as_start() -> void:
	start_global_position = global_position
	previous_global_position = global_position


func clear_slot() -> void:
	current_slot = null


func get_global_center() -> Vector2:
	return global_position + (size * 0.5)


func is_in_correct_slot() -> bool:
	if current_slot == null:
		return false

	var slot_id = current_slot.get("slot_id")

	if slot_id == null:
		return false

	return piece_id == int(slot_id)


func set_piece_id(new_piece_id: int) -> void:
	piece_id = new_piece_id

	if correct_slot_id <= 0:
		correct_slot_id = new_piece_id

	_update_image()


func set_locked(value: bool) -> void:
	locked = value


func _update_image() -> void:
	var texture_to_use := piece_texture

	if texture_to_use == null:
		var path := image_prefix + str(piece_id) + image_extension

		if ResourceLoader.exists(path):
			texture_to_use = load(path) as Texture2D
		else:
			push_warning("PhotoPiece: imagem não encontrada: " + path)
			return

	if photo_image == null:
		push_warning("PhotoPiece: PhotoImage não encontrado. Verifique o image_node_path.")
		return

	photo_image.texture = texture_to_use


func _update_locked_state() -> void:
	if locked:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		modulate.a = 0.6
	else:
		mouse_filter = Control.MOUSE_FILTER_STOP
		modulate.a = 1.0
