extends TestCase

class_name BasicModelTest

func test_find() -> void:
	var user = User.new().find(1)
	assert_equals("john.doe@example.com", user.get_attr("email"))

func test_newest() -> void:
	assert_equals(3, User.new().newest().get_id())

func test_count() -> void:
	assert_equals(2, User.new().count())
	
func test_max_id() -> void:
	assert_equals(3, User.new().max_id())

func test_reload() -> void:
	var user = User.new().find(1)
	
	# Update directly with a query (i.e. the model will not know about this)
	DataSource.get_default().query_with_bindings(
		"UPDATE users SET `email` = ? WHERE id = ?",
		[
			"john.doe.new@example.com",
			1,
		])
		
	# Integrity check:
	assert_equals("john.doe@example.com", user.get_attr("email"))
	
	user.reload()
	assert_equals("john.doe.new@example.com", user.get_attr("email"))
