extends MarginContainer

const FILE_STRING_TEMPLATE = "%s:%d (Function: %s)"

@onready var label_message: Label = $VBoxContainer/LabelMessage
@onready var label_expected: Label = $VBoxContainer/HBox_Expected/LabelExpected
@onready var label_actual: Label = $VBoxContainer/HBox_Actual/LabelActual
@onready var label_source: Label = $VBoxContainer/HBox_Source/LabelSource

@export var assertion: AssertionMeta:
	set(value):
		label_message.text = value.it
		label_expected.text = str(value.expected)
		label_actual.text = str(value.actual)
		label_source.text = FILE_STRING_TEMPLATE % [
			value.source.file,
			value.source.line,
			value.source.function,
		]
