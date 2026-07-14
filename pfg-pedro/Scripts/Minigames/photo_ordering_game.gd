extends Control
class_name PhotoOrderingGame

signal game_completed

var photos: Array[Photo] = []
var initial_order: Array[int] = [2, 4, 5, 1, 6, 3]
var current_order: Array[int] = []
var selected_photo: Photo = null


func _ready() -> void:
	photos.clear()

	for i in range(1, 7):
		var path := "PhotoSlot%d/PhotoContainer/Photo" % i
		var photo := get_node(path) as Photo
		photos.append(photo)

	current_order = initial_order.duplicate()

	_connect_photos()
	_update_album()


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	var key_event := event as InputEventKey

	if not key_event.pressed or key_event.echo:
		return

	var photo_id := _get_photo_id_from_key(key_event.keycode)

	if photo_id == -1:
		return

	var photo := _get_photo_by_id(photo_id)

	_on_photo_clicked(photo)
	get_viewport().set_input_as_handled()


func _get_photo_id_from_key(keycode: int) -> int:
	match keycode:
		KEY_1:
			return 1
		KEY_2:
			return 2
		KEY_3:
			return 3
		KEY_4:
			return 4
		KEY_5:
			return 5
		KEY_6:
			return 6
		_:
			return -1


func _get_photo_by_id(photo_id: int) -> Photo:
	for photo in photos:
		if photo.photo_id == photo_id:
			return photo

	return null


func _connect_photos() -> void:
	var callback := Callable(self, "_on_photo_clicked")

	for photo in photos:
		if not photo.photo_clicked.is_connected(callback):
			photo.photo_clicked.connect(callback)


func _update_album() -> void:
	for i in range(photos.size()):
		var photo_id := current_order[i]
		photos[i].setup(photo_id)
		photos[i].set_selected(false)

	selected_photo = null


func _on_photo_clicked(photo: Photo) -> void:
	if selected_photo == null:
		selected_photo = photo
		selected_photo.set_selected(true)
		return

	if selected_photo == photo:
		selected_photo.set_selected(false)
		selected_photo = null
		return

	_swap_photos(selected_photo, photo)

	if _is_album_correct():
		game_completed.emit()


func _swap_photos(photo_a: Photo, photo_b: Photo) -> void:
	var index_a := photos.find(photo_a)
	var index_b := photos.find(photo_b)

	var temp := current_order[index_a]
	current_order[index_a] = current_order[index_b]
	current_order[index_b] = temp

	_update_album()


func _is_album_correct() -> bool:
	for i in range(current_order.size()):
		if current_order[i] != i + 1:
			return false

	return true
