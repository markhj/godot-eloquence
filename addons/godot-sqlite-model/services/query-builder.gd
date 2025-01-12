extends Node

class_name QueryBuilder

# TODO: Convert to an object on its own
enum QueryType {
	Select,
	SelectSum,
}
var op_col: String
var query_type: QueryType = QueryType.Select

var model: SQLiteModel
var where_predicates: Array[WherePredicate]
var map_to_models: bool = true

var operator_mapping: Dictionary = {
	"=": WherePredicate.Operator.Equals,
	"!=": WherePredicate.Operator.EqualsNot,
}

# Order and limit
var ordering = null
var row_limit = null

func from(set_model: SQLiteModel) -> QueryBuilder:
	model = set_model
	return self

func raw() -> QueryBuilder:
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
	return model.make_instance().create(default)

func execute(data_source: SQLite = null) -> Array:
	if not data_source:
		data_source = DataSource.get_default()
	var list: Array
	data_source.query_with_bindings(to_sql(), to_bindings())
	for row in data_source.query_result:
		if map_to_models:
			list.append(model.make_instance().apply(row))
		else:
			list.append(row)
	return list

func where(column: String, operator_or_value, value = null) -> QueryBuilder:
	var predicate = WherePredicate.new()
	predicate.column = column
	
	if value == null:
		predicate.value = str(operator_or_value)
	else:
		predicate.value = str(value)
		assert(operator_mapping.has(operator_or_value),
			"Unknown operator in WHERE-predicate: %s" % [operator_or_value])
		
	where_predicates.append(predicate)
	return self
	
func where_null(column: String) -> QueryBuilder:
	var predicate = WherePredicate.new()
	predicate.operator = WherePredicate.Operator.IsNull
	predicate.column = column
	where_predicates.append(predicate)
	return self
	
func where_not_null(column: String) -> QueryBuilder:
	var predicate = WherePredicate.new()
	predicate.operator = WherePredicate.Operator.IsNotNull
	predicate.column = column
	where_predicates.append(predicate)
	return self

func order_by(column: String, order: String = "ASC") -> QueryBuilder:
	ordering = [column, order]
	return self

func random_order() -> QueryBuilder:
	ordering = ["random"]
	return self

func desc(column: String = "id") -> QueryBuilder:
	return order_by(column, "DESC")

func limit(to: int) -> QueryBuilder:
	assert(to > 0, "Limit must be greater than 0.")
	row_limit = to
	return self

func to_bindings() -> Array[String]:
	var bindings: Array[String]
	for predicate in where_predicates:
		# Ensure that a binding isn't added when it's an IS NULL or
		# IS NOT NULL check, which doesn't require one
		if [
			WherePredicate.Operator.IsNull,
			WherePredicate.Operator.IsNotNull,
		].find(predicate.operator) >= 0:
			continue
			
		bindings.append(predicate.value)
	return bindings

func sum(column: String) -> int:
	query_type = QueryType.SelectSum
	op_col = column
	
	# TODO: IMPORTANT: map_to_models must be temporary (probably needs passed as arg.)
	map_to_models = false
	
	var record = first()
	if not record or record.result == null:
		return 0
	
	return record.result

func to_sql() -> String:
	var query: String = "SELECT * FROM %s" % [model.get_table_name()]
	if query_type == QueryType.SelectSum:
		query = "SELECT SUM(%s) AS `result` FROM %s" % [op_col, model.get_table_name()]
	
	if where_predicates.size() > 0:
		var where_clause: String
		for predicate in where_predicates:
			if where_clause:
				where_clause += " AND "
			if predicate.operator == WherePredicate.Operator.Equals:
				where_clause += "`%s` = ?" % [predicate.column]
			if predicate.operator == WherePredicate.Operator.EqualsNot:
				where_clause += "`%s` != ?" % [predicate.column]
			elif predicate.operator == WherePredicate.Operator.IsNull:
				where_clause += "`%s` IS NULL" % [predicate.column]
			elif predicate.operator == WherePredicate.Operator.IsNotNull:
				where_clause += "`%s` IS NOT NULL" % [predicate.column]
		query += " WHERE %s " % [where_clause]
	if ordering:
		if ordering[0] == "random":
			query += " ORDER BY RANDOM()"
		else:
			query += " ORDER BY `%s` %s" % [ordering[0], ordering[1]]
	if row_limit:
		query += " LIMIT %d" % [row_limit]
	return query.strip_edges()
