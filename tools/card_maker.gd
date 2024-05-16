extends Control

@onready var ui_card_viewer: TrimmedCard = %Viewer
@onready var ui_load_illustration_file_dialog: FileDialog = %IllustrationFileDialog
@onready var ui_illustration: TextureRect = %Illustration
@onready var card_resource: CardData:
	get:
		return ui_card_viewer.card_data
	set(value):
		assert(false, "card_resource should not be set directly.")
@export var template_card = preload ("res://database/cards/ExampleCard.tres")

var update_scheduled := false
var card_data: CardData

@onready var ui_card_name: LineEdit = %CardNameEdit
@onready var ui_card_title: LineEdit = %CardTitleEdit
@onready var ui_flavor_text: LineEdit = %FlavorTextEdit
@onready var ui_rarity_list: AttributeItemList = %RarityList
@onready var ui_spirit_gain: AttributeItemList = %SpiritGenList
@onready var ui_level_items: AttributeItemList = %LevelItemList
@onready var ui_series_code: LineEdit = %SeriesLineEdit
@onready var ui_id_in_series: SpinBox = %SeriesNumberLineEdit
@onready var ui_year: SpinBox = %YearEdit
@onready var ui_artist_name: LineEdit = %ArtistEdit
@onready var ui_is_ai_assited: CheckBox = %IsAiAssited
@onready var ui_card_elements: AttributeItemList = %MainElementItemList
@onready var ui_unstagger_cost: AttributeItemList = %RecoverCostItemList
@onready var ui_combat_stats: AttributeItemList = %CombatStatsList
@onready var ui_support_items: AttributeItemList = %SupportItemList
@onready var ui_tenacity_stats: AttributeItemList = %TenacityStatList
@onready var ui_skills_editor: MakerSkillEditor = % "Skills Editor"
@onready var ui_load_card_dialog: FileDialog = %LoadCardDialog
@onready var ui_save_card_dialog: FileDialog = %SaveCardDialog
@onready var ui_paste_button: Button = %PasteButton
@onready var ui_viewer_viewport: Viewport = %ViewerViewport
@onready var ui_viewer_camera: Camera2D = %ViewerCamera
@onready var ui_export_file_dialog: FileDialog = %ExportFileDialog
@onready var ui_new_card_confirmation_dialog: ConfirmationDialog = %NewCardConfirmation
@onready var save_card_dialog: FileDialog = %SaveCardDialog
var share : Share

const CUSTOM_CARDS_DIR = "user://custom_cards"
const USER_DIR = "user://"
const OS_WEB = "Web"
const OS_ANDROID = "Android"
var file_access_web: FileAccessWeb

func _ready() -> void:

	if OS.get_name() == OS_WEB:
		file_access_web = FileAccessWeb.new()
	if OS.get_name() == OS_ANDROID:
		share = Share.new()
		add_child(share)
		#ask for android permissions
		OS.request_permissions()
		theme_type_variation = "Android"
		ui_load_illustration_file_dialog.root_subfolder = OS.get_environment("EXTERNAL_STORAGE")
		theme.default_font_size = 32
		set("theme_override_constants/margin_top",16)
		set("theme_override_constants/margin_bottom",16)

	var dir = DirAccess.open(USER_DIR)
	if not dir.dir_exists(CUSTOM_CARDS_DIR):
		dir.make_dir(CUSTOM_CARDS_DIR)
	ui_load_card_dialog.root_subfolder = CUSTOM_CARDS_DIR
	ui_save_card_dialog.root_subfolder = CUSTOM_CARDS_DIR
	create_new_card()
	schedule_update()
	get_viewport().size_changed.connect(update_card_viewer_zoom)
	update_card_viewer_zoom.call_deferred()

const DEFAULT_VIEWER_SIZE := Vector2(750, 1050)

func update_card_viewer_zoom() -> void:
	var zoom_level := 0.95
	var new_viewer_size = Vector2(min(get_viewport().size.x / 2, 750), min(get_viewport().size.y, 1050))
	ui_viewer_viewport.size = new_viewer_size
	var smaller_side = new_viewer_size / DEFAULT_VIEWER_SIZE
	var new_zoom_level = (min(smaller_side.x, smaller_side.y)) * zoom_level
	ui_viewer_camera.zoom = Vector2(new_zoom_level, new_zoom_level)

func create_new_card() -> void:
	card_data = template_card.duplicate(true)
	ui_card_viewer.card_data = card_data
	sync_ui_to_new_card()
	schedule_update()

func load_card(card) -> void:
	card_data = card.duplicate(true)
	ui_card_viewer.card_data = card_data
	sync_ui_to_loaded_card()

func sync_ui_to_new_card() -> void:
	ui_card_name.clear()
	card_data.name = template_card.name
	ui_card_title.clear()
	card_data.title = template_card.title
	ui_flavor_text.clear()
	card_data.flavor_text = template_card.flavor_text
	ui_illustration.texture = template_card.art
	if ui_series_code.text != StaticGlobals.EMPTY_STRING:
		card_data.series_name = ui_series_code.text
	ui_id_in_series.value += 1
	ui_rarity_list.select_by_key(card_data.rarity.key)
	var current_year = Time.get_date_dict_from_system().year
	ui_year.value = current_year
	sync_attributes_and_ui()
	sync_stats_and_ui()
	ui_skills_editor.skill_list = card_data.skills
	ui_skills_editor.sync_ui()

func sync_ui_to_loaded_card() -> void:
	ui_card_name.text = card_data.name
	ui_card_title.text = card_data.title
	ui_flavor_text.text = card_data.flavor_text
	ui_illustration.texture = card_data.art
	ui_id_in_series.value = card_data.card_id_in_series
	ui_series_code.text = card_data.series_name
	ui_rarity_list.select_by_key(card_data.rarity.key)
	ui_is_ai_assited.button_pressed = card_data.is_ai_asssited
	ui_artist_name.text = card_data.artist
	sync_attributes_and_ui()
	sync_stats_and_ui()
	ui_skills_editor.skill_list = card_data.skills
	ui_skills_editor.sync_ui()

func sync_attributes_and_ui() -> void:
	ui_card_elements.deselect_all()
	ui_card_elements.select_by_key(card_data.element.key)
	ui_unstagger_cost.deselect_all()
	ui_unstagger_cost.select_by_key(card_data.upkeep.key)
	ui_spirit_gain.deselect_all()
	if card_data.spirit_stats.size() >= 2:
		push_warning("Only 1 spirit stat is allowed. The rest will be ignored")
	ui_spirit_gain.deselect_all()
	ui_spirit_gain.select_by_key(card_data.spirit_stats[0].key)

func sync_stats_and_ui() -> void:
	ui_level_items.select_by_key(card_data.level.key)

func schedule_update() -> void:
	if not update_scheduled:
		update_scheduled = true
		update.call_deferred()

func update() -> void:
	if (update_scheduled):
		card_data.validate()
		ui_card_viewer.update.call_deferred()
		update_scheduled = false

const MOUSE_INPUT_UI_DELTAS = {
	MOUSE_BUTTON_RIGHT: - 1,
	MOUSE_BUTTON_WHEEL_DOWN: - 1,
	MOUSE_BUTTON_LEFT: 1,
	MOUSE_BUTTON_WHEEL_UP: 1
}

func get_delta(mouse_button_index: int) -> int:
	if MOUSE_INPUT_UI_DELTAS.has(mouse_button_index):
		return MOUSE_INPUT_UI_DELTAS[mouse_button_index]
	return 0


func _on_new_card_pressed() -> void:
	ui_new_card_confirmation_dialog.popup_centered()

func _on_new_card_confirmation_confirmed() -> void:
	create_new_card()
	schedule_update()

const ACCEPTED_ART_EXTENSIONS: String = ".jpg,.png,.webp"
func _on_upload_button_pressed() -> void:
	if OS.get_name() == "Web":
		file_access_web.open(ACCEPTED_ART_EXTENSIONS)
		file_access_web.loaded.connect(_on_file_loaded)
	else:
		ui_load_illustration_file_dialog.popup_centered()

func _on_file_loaded(file_name: String, type: String, base64_data: String) -> void:
	var raw_data: PackedByteArray = Marshalls.base64_to_raw(base64_data)
	var image := Image.new()
	var error: int = _load_image(image, type, raw_data)

	if not error:
		save_image(file_name, image)
	else:
		push_error("Error %s id" % error)
	schedule_update()

func _load_image(image: Image, type: String, data: PackedByteArray) -> int:
	match type:
		"image/png":
			return image.load_png_from_buffer(data)
		"image/jpeg":
			return image.load_jpg_from_buffer(data)
		"image/webp":
			return image.load_webp_from_buffer(data)
		_:
			return Error.FAILED

func _on_illustration_selected(path: String) -> void:
	var image := Image.load_from_file(path)
	save_image(path.get_file(), image)
	schedule_update()

const RESOURCES_DIR = "res://"
const DOWNLOADS_DIR = "res://downloads/"
func save_image(file_name: String, image: Image):
	var dir = DirAccess.open(RESOURCES_DIR)
	dir.make_dir(DOWNLOADS_DIR)
	var texture := ImageTexture.create_from_image(image)
	var texture_path = DOWNLOADS_DIR + file_name
	ResourceSaver.save(texture, texture_path)
	ui_illustration.texture = texture
	card_resource.art = texture

func _on_card_name_edit_text_changed(new_text) -> void:
	card_resource.name = new_text
	schedule_update()

func _on_card_title_edit_text_changed(new_text) -> void:
	card_resource.title = new_text
	schedule_update()

func _on_artist_changed(new_text: String) -> void:
	card_resource.artist = new_text
	schedule_update()

func _on_is_ai_assited_toggled(toggled_on: bool) -> void:
	card_resource.is_ai_asssited = toggled_on
	schedule_update()

func _on_year_edit_value_changed(value: int) -> void:
	card_resource.year = value
	schedule_update()

func _on_rarity_selected(index: int) -> void:
	card_data.rarity = ui_rarity_list.get_item_metadata(index)
	schedule_update()

func _on_main_element_list_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	var attribute: Attribute = ui_card_elements.get_item_metadata(index)
	var card_element := card_data.element
	var ui_item := ui_card_elements

	if attribute.key == ui_item.clear_item_list_item.key:
		if _mouse_button_index == MOUSE_BUTTON_LEFT:
			card_element.attribute = StaticGlobals.DEFAULT_ATTRIBUTE
			card_element.value = "-1"
		schedule_update()
		return

	card_element.attribute = attribute
	card_element.add_int(get_delta(_mouse_button_index))

	card_data.background_texture = card_element.attribute \
	.get_meta(StaticGlobals.CARD_BORDER_METAKEY, StaticGlobals.DEFAULT_CARD_BORDER)
	schedule_update()

func _on_series_number_line_edit_value_changed(value: float) -> void:
	card_resource.card_id_in_series = int(value)
	schedule_update()

func _on_series_line_edit_text_changed(new_text: String) -> void:
	card_resource.series_name = new_text
	schedule_update()

func _on_spirit_generation_list_item_clicked(index: int, _at_position: Vector2, mouse_button_index: int) -> void:
	var delta := get_delta(mouse_button_index)
	var attribute: Attribute = ui_spirit_gain.get_item_metadata(index)
	var key: String = attribute.key
	if key == ui_spirit_gain.clear_item_list_item.key:
		if mouse_button_index == MOUSE_BUTTON_LEFT:
			card_resource.spirit_stats.clear()
			schedule_update()
		return
	var stats = card_data.spirit_stats
	if stats.is_empty():
		var new_stat := Stat.new()
		new_stat.attribute = attribute
		stats.clear()
		stats.push_back(new_stat)
	elif stats.size() >= 2:
		push_warning("Only 1 spirit stat is allowed. The rest will be ignored")
	var stat: Stat = stats[0]
	stat.attribute = attribute
	stat.add_int(delta)
	card_data.spirit_stats.clear()
	card_data.spirit_stats.push_back(stat)
	schedule_update()

func _on_upkeep_list_item_clicked(index: int, _at_position: Vector2, mouse_button_index: int) -> void:
	var delta = get_delta(mouse_button_index)
	var attribute = ui_unstagger_cost.get_item_metadata(index)
	var key = attribute.key
	if key == ui_unstagger_cost.clear_item_list_item.key and mouse_button_index == MOUSE_BUTTON_MIDDLE:
		card_data.upkeep = Stat.new()
	card_data.upkeep.attribute = attribute
	card_data.upkeep.add_int(delta)
	schedule_update()

func _on_flavor_text_edit_text_changed(new_text: String) -> void:
	card_data.flavor_text = new_text
	schedule_update()

func _on_load_card_button_pressed() -> void:
	ui_load_card_dialog.popup_centered()

func _on_load_card_dialog_file_selected(path: String) -> void:
	load_card(load(path))
	schedule_update()


func _on_save_card_pressed() -> void:
	save_card_dialog.popup_centered()

const RESOURCE_EXTENSION = "tres"
func _on_save_card_dialog_file_selected(path: String) -> void:
	if path.get_extension() != RESOURCE_EXTENSION:
		path += "." + RESOURCE_EXTENSION
	ResourceSaver.save(card_data, path)

var combat_stats := {}
func _on_combat_stats_item_clicked(index: int, _at_position: Vector2, mouse_button_index: int) -> void:
	var delta := get_delta(mouse_button_index)
	var attribute: Attribute = ui_combat_stats.get_item_metadata(index)
	var key := attribute.key
	ui_combat_stats.deselect_all()
	if key == ui_combat_stats.clear_item_list_item.key:
		if mouse_button_index == MOUSE_BUTTON_LEFT:
			combat_stats.clear()
		card_data.combat_stats.assign(combat_stats.values())
		schedule_update()
		return

	if not combat_stats.has(key):
		combat_stats[key] = Stat.new()
	var new_stat = combat_stats[key]
	new_stat.attribute = attribute
	new_stat.add_int(delta, -1)
	card_data.combat_stats.assign(combat_stats.values())
	schedule_update()

func _on_level_item_list_item_selected(index: int) -> void:
	var atttribute = ui_level_items.get_item_metadata(index)
	card_data.level.attribute = atttribute
	schedule_update()

var support_items := {}
func _on_support_item_list_item_clicked(index: int, _at_position: Vector2, mouse_button_index: int) -> void:
	var delta := get_delta(mouse_button_index)
	var attribute: Attribute = ui_support_items.get_item_metadata(index)
	var key := attribute.key
	ui_support_items.deselect_all()
	if key == ui_support_items.clear_item_list_item.key and mouse_button_index == MOUSE_BUTTON_LEFT:
		support_items.clear()
		card_data.supply_generation.clear()
		schedule_update()
		return
	if not support_items.has(key):
		var new_stat = Stat.new()
		support_items[key] = new_stat
	var stat_to_edit = support_items[key]
	stat_to_edit.attribute = attribute
	stat_to_edit.add_int(delta, 0)
	if mouse_button_index == MOUSE_BUTTON_MIDDLE or int(stat_to_edit.value) <= 0:
		support_items.erase(key)

	card_data.supply_generation.assign(support_items.values())
	schedule_update()

var _tenacity_stats := {}
func _on_tenacity_stat_list_item_clicked(index: int, _at_position: Vector2, mouse_button_index: int) -> void:
	var delta := get_delta(mouse_button_index)
	var attribute: Attribute = ui_tenacity_stats.get_item_metadata(index)
	var key := attribute.key
	ui_tenacity_stats.deselect_all()
	if key == ui_tenacity_stats.clear_item_list_item.key and mouse_button_index == MOUSE_BUTTON_LEFT:
		_tenacity_stats.clear()
		card_data.tenacity_stats.assign(_tenacity_stats.values())
		schedule_update()
		return
	var new_stat := Stat.new()
	new_stat.attribute = attribute
	if not _tenacity_stats.has(key):
		_tenacity_stats[key] = new_stat
	elif mouse_button_index == MOUSE_BUTTON_MIDDLE:
		_tenacity_stats.erase(key)
		card_data.tenacity_stats.assign(_tenacity_stats.values())
		schedule_update()
		return
	_tenacity_stats[key].add_int(delta)
	if int(_tenacity_stats[key].value) < 0:
		_tenacity_stats.erase(key)
	card_data.tenacity_stats.assign(_tenacity_stats.values())
	schedule_update()


func _on_export_card_button_pressed() -> void:
	if OS.get_name() == OS_WEB:
		export_card_web()
	if OS.get_name() == StaticGlobals.OS_NAMES.ANDROID:
		export_card_android()
	else:
		ui_export_file_dialog.current_dir = OS.get_user_data_dir()
		var file_name_suggestion = "%s-%s-%s.png" % [card_data.name, card_data.series_name, card_data.card_id_in_series]
		ui_export_file_dialog.current_file = file_name_suggestion
		ui_export_file_dialog.popup_centered()

func _on_export_file_dialog_file_selected(path: String) -> void:
	ui_viewer_viewport.size = DEFAULT_VIEWER_SIZE
	ui_viewer_camera.zoom = Vector2.ONE
	var directory = path.get_base_dir()
	var file := path.get_file().validate_filename()
	if not file.ends_with(".png"):
		file += ".png"
	var new_path := directory.path_join(file)
	await RenderingServer.frame_post_draw
	var screenshot := await get_card_image()
	screenshot.save_png(new_path)
	await RenderingServer.frame_post_draw
	update_card_viewer_zoom()

func get_card_image() -> Image:
	ui_viewer_viewport.size = DEFAULT_VIEWER_SIZE
	ui_viewer_camera.zoom = Vector2.ONE
	await RenderingServer.frame_post_draw
	var screenshot: Image = ui_card_viewer.get_viewport().get_texture().get_image()
	return screenshot

func export_card_android() -> void:
	var screenshot := await get_card_image()
	var file_name_suggestion = "%s-%s-%s.png" % [card_data.name, card_data.series_name, card_data.card_id_in_series]
	var data_dir = OS.get_user_data_dir()
	var path = data_dir.path_join(file_name_suggestion)
	screenshot.save_png(path)
	share.share_image(path,file_name_suggestion,"Touhou Card","")

func export_card_web() -> void:
	var screenshot := await get_card_image()
	var buffer := screenshot.save_png_to_buffer()
	var file_name_suggestion = "%s-%s-%s.png" % [card_data.name, card_data.series_name, card_data.card_id_in_series]
	JavaScriptBridge.download_buffer(buffer, "%s" % file_name_suggestion, "image/png")

func _on_skills_editor_skill_changed() -> void:
	schedule_update()

