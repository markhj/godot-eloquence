extends Resource

class_name WherePredicate

enum Operator {
	IsNull,
	IsNotNull,
	Equals,
	EqualsNot,
}

@export var column: String
@export var operator: Operator = Operator.Equals
@export var value: String
