extends Resource

class_name SQLiteModel

@export var table: TableDefinition
@export var attributes: AttributeBag = AttributeBag.new()

# The first loaded (or last saved) state of the attributes.
# Used during saving of the model to compare if any changes were made.
@export var original: AttributeBag = AttributeBag.new()

func _init():
	setup()
	
	assert(table, "Table undefined in %s" % [get_model_name()])

func setup() -> void:
	pass
	
func setup_relations() -> void:
	pass

func query() -> QueryBuilder:
	return QueryBuilder.new().from(make_instance())

func make_instance() -> SQLiteModel:
	return get_script().new()

func apply(raw: Dictionary) -> SQLiteModel:
	attributes.apply(raw)
	original.apply(raw.duplicate())
	on_load()
	return self

func get_id() -> int:
	assert(attributes.data.has("id"), "Data is not loaded, or there is no \"id\" column.")
	return attributes.data.id

func get_model_name() -> String:
	return get_script().get_global_name()

func get_table_name() -> String:
	return table.table_name

func get_data_source() -> SQLite:
	return DataSource.get_default()

func get_attr(key: String):
	assert(attributes.data.has(key), "%s does not contain %s" % [get_model_name(), key])
	return attributes.data[key]
	
func set_attr(key: String, value) -> SQLiteModel:
	if is_loaded():
		assert(attributes.data.has(key), "%s does not contain %s" % [get_model_name(), key])
	attributes.data[key] = value
	return self

func is_loaded() -> bool:
	return attributes.data.has("id")

func on_load() -> void:
	pass
	
func on_save() -> void:
	pass

func before_save() -> void:
	pass

func validate_before_save() -> bool:
	return true
	
func on_validation_error() -> void:
	pass

func _query(query: String, bindings: Array = []) -> Array:
	var source = get_data_source()
	var records = source.query_with_bindings(query, bindings)
	return source.query_result

func find(id: int):
	return QueryBuilder.new().from(make_instance()).where("id", id).first()

func newest():
	return QueryBuilder.new().from(make_instance()).order_by("id", "desc").limit(1).first()

# TODO: Improve error handling when insert fails
func create(data: Dictionary) -> SQLiteModel:
	var setters: String
	var placeholders: String
	var bindings: Array
	for key in data:
		if not setters.is_empty():
			setters += ", "
			placeholders += ", "
		setters += "`%s`" % [key]
		placeholders += "?"
		bindings.append(data[key])
	
	var query = "INSERT INTO %s (%s) VALUES (%s)" % [get_table_name(), setters, placeholders]
	get_data_source().query_with_bindings(query, bindings)
	return newest()

func save() -> void:
	if not validate_before_save():
		on_validation_error()
		return
	
	# before_save must run before checking original and current
	# attribute state, as it's likely to make updates in the current state.
	before_save()
	
	# When original and current state are identical, we will not
	# "waste energy" carrying out the update query.
	if original.data == attributes.data and is_loaded():
		return
	
	if is_loaded():
		_exec_update()
		original.apply(attributes.data.duplicate())
	else:
		_exec_insert()
	
	on_save()

func _exec_update() -> void:
	var setters: String
	var bindings: Array
	for attr_key in attributes.data:
		if attr_key != "id":
			if not setters.is_empty():
				setters += ", "
			setters += "`%s` = ?" % attr_key
			bindings.append(attributes.data[attr_key])
			
	bindings.append(get_id())
	
	var query = "UPDATE %s SET %s WHERE id = ?" % [get_table_name(), setters]
	_query(query, bindings)
	
func _exec_insert() -> void:
	var columns: String
	var values: String
	var bindings: Array
	
	for attr_key in attributes.data:
		if not columns.is_empty():
			columns += ", "
			values += ", "
		columns += "`%s`" % [attr_key]
		values += "?"
		bindings.append(attributes.data[attr_key])
	
	var query = "INSERT INTO %s (%s) VALUES (%s)" % [
		get_table_name(),
		columns,
		values,
	]
	_query(query, bindings)
	
	set_attr("id", get_data_source().last_insert_rowid)
	
	# A hard reload is necessary to also load values which may have
	# been created as default values by the table.
	reload()

func get_relation(res: Resource) -> SQLiteModel:
	var result = get_relations(res, [
		TableRelation.RelationType.BelongsTo,
		TableRelation.RelationType.HasOne,
	])
	if result.size() > 0:
		return result[0]
	else:
		return null

func get_relations(res: Resource, relation_types: Array = []) -> Array:
	table.relations.clear()
	setup_relations()
	
	var identifier = res.new().get_model_name()
	var list: Array
	for relation in table.relations:
		if relation.identifier != identifier:
			continue
		if not relation_types.is_empty() and relation_types.find(relation.type) < 0:
			continue
		var query = "SELECT * FROM %s WHERE %s = ?"
		query %= [relation.foreign_table, relation.foreign_column]
		var bindings = [attributes.data[relation.local_column]]
		for record in _query(query, bindings):
			list.append(relation.map_to_model.new().apply(record))
	return list

func reload() -> void:
	var records = _query(
		"SELECT * FROM %s WHERE `id` = ?" % [get_table_name()],
		[get_id()],
	)
	apply(records[0])

func count() -> int:
	return query_table_meta("COUNT(id)")

func max_id() -> int:
	return query_table_meta("MAX(id)")

func query_table_meta(select: String) -> int:
	return _query("SELECT %s AS result FROM %s" % [select, get_table_name()])[0]["result"]

func all() -> Array:
	var list: Array
	for record in _query("SELECT * FROM %s" % [get_table_name()], []):
		list.append(make_instance().apply(record))
	return list
