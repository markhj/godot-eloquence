extends TestCase

class_name RelationsTest

func test_belongs_to() -> void:
	var permission = Permission.new().find(1)
	var user = permission.get_relation(User)
	
	assert_equals(1, user.get_id())

func test_has_many() -> void:
	var user = User.new().find(1)
	var permissions = user.get_relations(Permission)
	
	assert_equals(2, permissions.size())
	assert_equals("POSTS_CREATE", permissions[0].get_attr("permission"))
	assert_equals("POSTS_DELETE", permissions[1].get_attr("permission"))
