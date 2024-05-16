class_name  TrimmedCard
extends Control
@onready var ui_card = $CenterContainer/Card

@export var card_data : CardData = preload("res://database/cards/ExampleCard.tres"):
	set(value):
		if not value:
				assert(false,"Don't set card_data to null.")
		card_data = value

func _ready():
	ready.connect(update)
	update.call_deferred()

func update():
	if is_node_ready():
		ui_card.card_data = card_data
		ui_card.fill_in()
		ui_card.update.call_deferred()

func take_screenshot(path:String) -> void:
	await RenderingServer.frame_post_draw
	var screenshot: Image = get_viewport().get_texture().get_image()
	screenshot.save_png(path)

func get_screenshot_path() -> String:
	var date = Time.get_date_string_from_system().replace(".", "_")
	var time : String = Time.get_time_string_from_system().replace(":", "")
	return "user://screenshot_{0}_{1}.png".format([date,time])

func _input(event:InputEvent):
	if event.is_action_pressed("ui_accept"):
		take_screenshot(get_screenshot_path())
