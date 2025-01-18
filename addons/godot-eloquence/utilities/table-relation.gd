extends Resource

class_name TableRelation

enum RelationType {
	BelongsTo,
	HasOne,
	HasMany,
}

@export var identifier: String
@export var type: RelationType
@export var local_column: String
@export var foreign_table: String
@export var foreign_column: String
@export var map_to_model: Resource

static func belongs_to(map_to_model: Resource,
	local_column: String,
	foreign_column: String = "id") -> TableRelation:
	var temp_instance = map_to_model.new()
	var relation = TableRelation.new()
	relation.type = RelationType.BelongsTo
	relation.identifier = temp_instance.get_model_name()
	relation.local_column = local_column
	relation.foreign_table = temp_instance.get_table_name()
	relation.foreign_column = foreign_column
	relation.map_to_model = map_to_model
	return relation

static func has_one(map_to_model: Resource,
	foreign_column: String,
	local_column: String = "id") -> TableRelation:
	var temp_instance = map_to_model.new()
	var relation = TableRelation.new()
	relation.type = RelationType.HasOne
	relation.identifier = temp_instance.get_model_name()
	relation.local_column = local_column
	relation.foreign_table = temp_instance.get_table_name()
	relation.foreign_column = foreign_column
	relation.map_to_model = map_to_model
	return relation

static func has_many(map_to_model: Resource,
	foreign_column: String,
	local_column: String = "id") -> TableRelation:
	var temp_instance = map_to_model.new()
	var relation = TableRelation.new()
	relation.type = RelationType.HasMany
	relation.identifier = temp_instance.get_model_name()
	relation.local_column = local_column
	relation.foreign_table = temp_instance.get_table_name()
	relation.foreign_column = foreign_column
	relation.map_to_model = map_to_model
	return relation
