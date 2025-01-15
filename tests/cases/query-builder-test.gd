extends TestCase

class_name QueryBuilderTest

func test_all() -> void:
	var builder = User.new().query()
	assert_equals("SELECT * FROM users", builder.to_sql())
	
func test_where() -> void:
	var builder = User.new().query()
	builder.where("id", 5)
	assert_equals("SELECT * FROM users WHERE `id` = ?", builder.to_sql())
	assert_equals(["5"], builder.to_bindings())
	
func test_where_null() -> void:
	var builder = User.new().query().where_null("email")
	assert_equals("SELECT * FROM users WHERE `email` IS NULL", builder.to_sql())
	
func test_where_not_null() -> void:
	var builder = User.new().query().where_not_null("email")
	assert_equals("SELECT * FROM users WHERE `email` IS NOT NULL", builder.to_sql())
	
func test_order_by() -> void:
	var builder = User.new().query().order_by("id")
	assert_equals("SELECT * FROM users ORDER BY `id` ASC", builder.to_sql())
	
func test_order_by_desc() -> void:
	var builder = User.new().query().order_by("id", "DESC")
	assert_equals("SELECT * FROM users ORDER BY `id` DESC", builder.to_sql())
	
func test_random_order() -> void:
	var builder = User.new().query().random_order()
	assert_equals("SELECT * FROM users ORDER BY RANDOM()", builder.to_sql())
	
func test_desc() -> void:
	var builder = User.new().query().desc()
	assert_equals("SELECT * FROM users ORDER BY `id` DESC", builder.to_sql())
	
	var b = User.new().query().desc("alt_column")
	assert_equals("SELECT * FROM users ORDER BY `alt_column` DESC", b.to_sql())
	
func test_limit() -> void:
	var builder = User.new().query().limit(5)
	assert_equals("SELECT * FROM users LIMIT 5", builder.to_sql())
	
func test_sum() -> void:
	var builder = User.new().query().sum("points")
	assert_equals("SELECT SUM(points) AS `result` FROM users", builder.to_sql())
	
func test_count() -> void:
	var builder = User.new().query().count("id")
	assert_equals("SELECT COUNT(id) AS `result` FROM users", builder.to_sql())
	
func test_min() -> void:
	var builder = User.new().query().minimum("id")
	assert_equals("SELECT MIN(id) AS `result` FROM users", builder.to_sql())
	
func test_max() -> void:
	var builder = User.new().query().maximum("id")
	assert_equals("SELECT MAX(id) AS `result` FROM users", builder.to_sql())
	
func test_avg() -> void:
	var builder = User.new().query().avg("points")
	assert_equals("SELECT AVG(points) AS `result` FROM users", builder.to_sql())
