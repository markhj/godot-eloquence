extends Node

class_name QueryType

enum PrimaryType {
	Select,
	SelectAsResult,
}

enum Function {
	None,
	SUM,
	COUNT,
	MAX,
	MIN,
	AVG,
}

@export var primary_type: PrimaryType = PrimaryType.Select

@export var function: Function = Function.None

@export var target_column: String
