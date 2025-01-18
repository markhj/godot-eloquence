extends TestCase

class_name ModelIOTest

# When a model has not yet been saved, an INSERT operation
# must be carried out on ``save``, and an ID must be assigned
func test_create() -> void:
	var new_user = User.new()
	new_user.set_attr("email", "new.user@example.com")
	new_user.save()
	
	assert_equals(4, new_user.get_id())
	assert_equals(3, User.new().query().count().do().get_result())

func test_save() -> void:
	var user = User.new().find(3)
	user.set_attr("email", "jane.done.2@example.com")
	user.save()
	
	var compare = User.new().find(3)
	assert_equals("jane.done.2@example.com", compare.get_attr("email"))
