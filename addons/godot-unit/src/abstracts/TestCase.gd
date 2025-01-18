extends Node

class_name TestCase

var result: TestResult = TestResult.new()

# When true, results are not appended to the TestResult object
var _silent: bool = false

# A "meta-level" function which is used for self-testing GodotUnit
# You will not need this function in everyday-life.
# It functions by silencing the actual assertion, and instead uses
# the result produced by the assertion for analysis.
func reflective(must_pass: bool, fn: Callable) -> void:
	_silent = true
	var assertion: AssertionMeta = fn.call()
	_silent = false
	assert_equals(must_pass, assertion.passed, assertion.it)

# Assert that an actual value matches an expected value.
func assert_equals(expected: Variant, actual: Variant, it: String = "") -> AssertionMeta:
	return _assert(expected == actual, expected, actual, it)

# Assert that a given (actual) values does NOT match the expected value.
func assert_not_equals(expected: Variant, actual: Variant, it: String = "") -> AssertionMeta:
	return _assert(expected != actual, expected, actual, it)

# Assert that the given bool is true.
func assert_true(actual: bool, it: String = "") -> AssertionMeta:
	return _assert(actual, true, actual, it)

# Assert that the given bool is false.
func assert_false(actual: bool, it: String = "") -> AssertionMeta:
	return _assert(not actual, false, actual, it)

func assert_null(actual: Variant, it: String = "") -> AssertionMeta:
	return _assert(actual == null, null, actual, it)

func assert_not_null(actual: Variant, it: String = "") -> AssertionMeta:
	return _assert(actual != null, null, actual, it)

func assert_count(expected: int, iterable: Array, it: String = "") -> AssertionMeta:
	return _assert(iterable.size() == expected, expected, iterable.size(), it)

func assert_empty(iterable: Array, it: String = "") -> AssertionMeta:
	return assert_count(0, iterable, it)

# Private helper function used as foundation for all assert_* functions.
# It produces an AssertionMeta instance which is populated with data,
# which can be used to identify where the assertion was made in case
# it does not pass.
func _assert(is_passed: bool,
	expected: Variant,
	actual: Variant,
	it: String
) -> AssertionMeta:
	# Find the method in the stack which called this assertion
	var stack_entry: Dictionary = find_stack_entry()
	
	var meta = AssertionMeta.new()
	meta.passed = is_passed
	meta.expected = expected
	meta.actual = actual
	
	# Use the provided "it" (description), or create a default one
	# with reference to where the assertion was called.
	if it:
		meta.it = it
	else:
		meta.it = "%s at line %d" % [
			stack_entry.function,
			stack_entry.line,
		]
	
	meta.source = FileSource.new()
	meta.source.file = stack_entry.source
	meta.source.line = stack_entry.line
	meta.source.function = stack_entry.function
	
	# In standard-scenario the findings of this assertion
	# will be reported to the TestResult instance.
	if not _silent:
		result.assertions.append(meta)
		result.tests += 1
		if expected == actual:
			result.passed += 1
	
	return meta

# Looks through the call-stack to identify which test_* method
# contains the assertion.
func find_stack_entry() -> Dictionary:
	var stack = get_stack()
	for entry in stack:
		if entry.function.begins_with("test_"):
			return entry
	return stack.back()
