extends TestCase

class_name QueryExecuteTest

func test_first() -> void:
	assert_equals(1, User.new().query().do().first().get_id())

func test_sum() -> void:
	assert_equals(149, User.new().query().sum("points").do().get_result())
	
func test_first_or_create() -> void:
	var test_email = "hello.world@example.com"
	var query = User.new().query().where("email", test_email)
	
	# Integrity check:
	assert_equals(3, User.new().query().count().do().get_result())
	assert_equals(null, query.do().first())
	
	User.new().query().where("email", test_email).do().first_or_create({
		"email": test_email,
	})
	
	# Verify that the record has been created
	assert_equals(4, User.new().query().count().do().get_result())
	assert_equals(test_email, query.do().first().get_attr("email"))
	
	# Verify that the email is not created again
	User.new().query().where("email", test_email).do().first_or_create({
		"email": test_email,
	})
	assert_equals(4, User.new().query().count().do().get_result())
