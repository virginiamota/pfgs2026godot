extends Node
class_name AlbumManager

var page_games: Array[PackedScene]

@onready var page_container: Control = $"../UI/Album/PageGameContainer"
@onready var previous_button: UIButton = $"../UI/Album/PreviousPageButton"
@onready var next_button: UIButton = $"../UI/Album/NextPageButton"
@onready var page_number_label: Label = $"../UI/Album/PageNumber"

var current_page: int = 0
var current_game: Node = null

var keyboard_locked: bool = false
var keyboard_press_time: float = 0.08

func _ready() -> void:
	const PATH = "res://Scenes/Minigames/"
	var minigames_files: PackedStringArray = DirAccess.open(PATH).get_files()
	for file in minigames_files:
		var packed_scene := load(PATH + file) as PackedScene
		page_games.append(packed_scene)
	
	previous_button.pressed.connect(_on_previous_pressed)
	next_button.pressed.connect(_on_next_pressed)
	
	load_page(0)

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	var key_event := event as InputEventKey

	if not key_event.pressed or key_event.echo:
		return

	if key_event.keycode == KEY_LEFT:
		await _change_page_with_keyboard(previous_button, current_page - 1)
		get_viewport().set_input_as_handled()

	if key_event.keycode == KEY_RIGHT:
		await _change_page_with_keyboard(next_button, current_page + 1)
		get_viewport().set_input_as_handled()

func load_page(page_index: int) -> void:
	_clear_current_game()

	current_page = page_index

	var game_scene: PackedScene = page_games[current_page]

	current_game = game_scene.instantiate()

	if current_game.has_signal("game_completed"):
		current_game.connect("game_completed", Callable(self, "_on_game_completed"))

	page_container.add_child(current_game)

	_update_ui()


func _clear_current_game() -> void:
	if current_game == null:
		return

	if current_game.get_parent() != null:
		current_game.get_parent().remove_child(current_game)

	current_game.queue_free()
	current_game = null


func _update_ui() -> void:
	page_number_label.text = str(current_page + 1) + " / " + str(page_games.size())

	previous_button.disabled = current_page == 0
	next_button.disabled = current_page == page_games.size() - 1


func _on_previous_pressed() -> void:
	load_page(current_page - 1)


func _on_next_pressed() -> void:
	load_page(current_page + 1)
	
func _change_page_with_keyboard(button: UIButton, target_page: int) -> void:
	if keyboard_locked:
		return

	if target_page < 0 or target_page >= page_games.size():
		return

	if button.disabled:
		return

	keyboard_locked = true

	button._on_button_down()
	await get_tree().create_timer(keyboard_press_time).timeout
	button._on_button_up()

	load_page(target_page)

	keyboard_locked = false


func _on_game_completed() -> void:
	print("Minigame da página ", current_page + 1, " completo.")
