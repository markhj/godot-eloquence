extends Control

const COLOR_FAILED: Color = Color(1.0, 0.05, 0.08)

const MARGIN: float = 15.0

const FAILURE_ITEM: PackedScene = preload("./FailureItem.tscn")

var results: TestResult:
	set(value):
		results = value
		refresh_summary()

@onready var label_total: Label = $HBox_Outer/MG_Summary/HBox_Summary/VBox_Total/LabelTotal
@onready var label_passed: Label = $HBox_Outer/MG_Summary/HBox_Summary/VBox_Passed/LabelPassed
@onready var label_failed: Label = $HBox_Outer/MG_Summary/HBox_Summary/VBox_Failed/LabelFailed

@onready var container_scroll: ScrollContainer = $HBox_Outer/MG_FailureList/ScrollContainer
@onready var container_failures: BoxContainer = $HBox_Outer/MG_FailureList/ScrollContainer/VBox_Failures

func _ready():
	get_viewport().connect("size_changed", size_changed)
	size_changed()

func refresh_summary() -> void:
	set_summary(results)
	set_failure_list(results)

func size_changed() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	container_scroll.custom_minimum_size.x = viewport_size.x - MARGIN
	container_scroll.custom_minimum_size.y = viewport_size.y - $HBox_Outer/MG_Summary.size.y - MARGIN

func set_summary(results: TestResult) -> void:
	var failed: int = results.tests - results.passed
	
	label_total.text = str(results.tests)
	label_passed.text = str(results.passed)
	label_failed.text = str(failed)
	
	if failed > 0:
		label_failed.label_settings.font_color = COLOR_FAILED

func set_failure_list(results: TestResult) -> void:	
	for assertion in results.assertions:
		if not assertion.passed:
			var item = FAILURE_ITEM.instantiate()
			container_failures.add_child(item)
			item.assertion = assertion
