extends SQLiteModel

class_name Permission

func setup() -> void:
	table = TableDefinition.create("permissions")

func setup_relations() -> void:
	table.relations.append(TableRelation.belongs_to(User, "user_id"))
