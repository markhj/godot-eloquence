extends Node

class_name QueryExecute

@export var query_builder: QueryBuilder
@export var map_to_models: bool = true

# Note: Must be called prior to every execution in which you
# don't want the results mapped to the respective model
func raw() -> QueryExecute:
	map_to_models = false
	return self

func first():
	var results = execute()
	if results.size() > 0:
		return results.front()
	else:
		return null
		
func first_or_create(default: Dictionary):
	var record = first()
	if record:
		return record
	return query_builder.model.make_instance().create(default)

func get_result():
	assert([
		QueryType.PrimaryType.SelectAsResult,
	].find(query_builder.query_type.primary_type) >= 0, "Cannot fetch result on this primary type.")
	
	return raw().first().result

func execute(data_source: SQLite = null) -> Array:
	if not data_source:
		data_source = DataSource.get_default()
	var list: Array
	data_source.query_with_bindings(query_builder.to_sql(), query_builder.to_bindings())
	for row in data_source.query_result:
		if map_to_models:
			list.append(query_builder.model.make_instance().apply(row))
		else:
			list.append(row)
			
	# Set back to default state
	map_to_models = true
	
	return list
