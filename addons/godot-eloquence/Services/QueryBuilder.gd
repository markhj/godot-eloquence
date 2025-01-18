extends Node

class_name QueryBuilder

var query_type: QueryType = QueryType.new()

var model: SQLiteModel

var where_predicates: Array[WherePredicate]

var operator_mapping: Dictionary = {
	"=": WherePredicate.Operator.Equals,
	"!=": WherePredicate.Operator.EqualsNot,
}

# Order and limit
var ordering = null
var row_limit = null

func on(set_model: SQLiteModel) -> QueryBuilder:
	model = set_model
	return self

func do() -> QueryExecute:
	assert(!!model, "Model is not set.")
	var execute = QueryExecute.new()
	execute.query_builder = self
	return execute

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

func sum(column: String) -> QueryBuilder:
	return select_as_result(column, QueryType.Function.SUM)

func count(column: String = "id") -> QueryBuilder:
	return select_as_result(column, QueryType.Function.COUNT)

func minimum(column: String) -> QueryBuilder:
	return select_as_result(column, QueryType.Function.MIN)

func maximum(column: String) -> QueryBuilder:
	return select_as_result(column, QueryType.Function.MAX)

func avg(column: String) -> QueryBuilder:
	return select_as_result(column, QueryType.Function.AVG)
	
func select_as_result(column: String, function: QueryType.Function) -> QueryBuilder:
	query_type.primary_type = QueryType.PrimaryType.SelectAsResult
	query_type.function = function
	query_type.target_column = column
	return self

func to_sql() -> String:
	# TODO: Parse in helper class
	var query: String = "SELECT * FROM %s" % [model.get_table_name()]
	if query_type.primary_type == QueryType.PrimaryType.SelectAsResult:
		assert([
			QueryType.Function.SUM,
			QueryType.Function.COUNT,
			QueryType.Function.MIN,
			QueryType.Function.MAX,
			QueryType.Function.AVG,
		].find(query_type.function) >= 0, "Function not allowed in 'Select As Result' mode")
		
		query = "SELECT %s(%s) AS `result` FROM %s" % [
			QueryType.Function.keys()[query_type.function],
			query_type.target_column,
			model.get_table_name(),
		]
	
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
