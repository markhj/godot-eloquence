extends Resource

class_name TableDefinition

@export var table_name: String
@export var relations: Array[TableRelation]

static func create(table_name: String) -> TableDefinition:
	var def = TableDefinition.new()
	def.table_name = table_name
	return def
