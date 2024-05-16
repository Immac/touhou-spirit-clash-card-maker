class_name BaseCard
extends Control

@export var card_data: CardData = preload ("res://database/cards/ExampleCard.tres")
@onready var ui_card_name: Label = %CardName
@onready var ui_card_title: Label = %CardTitle
@onready var ui_art := %Art
@onready var ui_bleed := %Bleed
@onready var ui_set_info_text = %SetInfoText
@onready var ui_level = %Level
@onready var ui_upkeep = %Upkeep
@onready var ui_supply_stats = %SupplyStats
@onready var ui_combat_stats = %CombatStats
@onready var ui_spirit_stats = %SpiritStats
@onready var ui_tenacity_stats = %TenacityStats
@onready var ui_skill_list = %SkillList
@onready var ui_flavor_text := % "Flavor Text"

var ai_assisted_attribute: Attribute = preload ("res://database/attributes/ui/ai_assised.tres")
func _ready():
	update()

func update():
	fill_in.call_deferred()

func fill_in():
	ui_art.texture = card_data.art
	ui_bleed.texture = card_data.background_texture
	var text_for_ai_assisted: String = str(ai_assisted_attribute.key) if card_data.is_ai_asssited else ""
	ui_set_info_text.text = "[center] %s-%04d | %s %s | %s | %04d" \
	% [card_data.series_name, card_data.card_id_in_series, card_data.artist, text_for_ai_assisted, card_data.rarity.key, card_data.year]
	ui_card_name.text = card_data.name
	ui_card_title.text = card_data.title
	ui_level.stat = card_data.element
	ui_level.update.call_deferred()
	ui_upkeep.stat = card_data.upkeep
	ui_upkeep.update.call_deferred()
	ui_supply_stats.stats = card_data.supply_generation
	ui_supply_stats.update.call_deferred()
	ui_combat_stats.stats.clear()
	ui_combat_stats.stats.push_back(card_data.level)
	ui_combat_stats.stats.append_array(card_data.combat_stats)
	ui_combat_stats.update.call_deferred()
	ui_spirit_stats.stats = card_data.spirit_stats
	ui_spirit_stats.update.call_deferred()
	ui_tenacity_stats.stats = card_data.tenacity_stats
	ui_tenacity_stats.update.call_deferred()
	ui_skill_list.skill_list = card_data.skills
	ui_skill_list.update.call_deferred()
	ui_flavor_text.clear()
	ui_flavor_text.push_italics()
	ui_flavor_text.add_text(card_data.flavor_text)
	ui_flavor_text.pop()

func take_screenshot(path: String) -> void:
	await RenderingServer.frame_post_draw
	var region: Rect2i = get_global_rect()
	var screenshot: Image = get_viewport().get_texture().get_image()
	var cropped = Image.create(region.size.x, region.size.y, false, screenshot.get_format())
	cropped.blit_rect(screenshot, region, Vector2i.ZERO)
	cropped.save_png(path)

func get_screenshot_path() -> String:
	var date = Time.get_date_string_from_system().replace(".", "_")
	var time: String = Time.get_time_string_from_system().replace(":", "")
	return "user://screenshot_{0}_{1}.png".format([date, time])
