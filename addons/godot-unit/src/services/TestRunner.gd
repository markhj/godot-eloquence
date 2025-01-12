extends Node

class_name TestRunner

func run(cases: Array[TestCase]) -> TestResult:
	var total: TestResult = TestResult.new()
	for case in cases:
		for method in case.get_method_list():
			if method.name.begins_with("test_"):
				case[method.name].call()
				
		total.tests += case.result.tests
		total.passed += case.result.passed
		total.assertions.append_array(case.result.assertions)
	return total
