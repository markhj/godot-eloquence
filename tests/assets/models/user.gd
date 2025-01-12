extends SQLiteModel

class_name User

func setup() -> void:
	table = TableDefinition.create("users")

func setup_relations() -> void:
	table.relations.append(TableRelation.has_many(Permission, "user_id"))
