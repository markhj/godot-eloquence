extends Node

class_name Results2ConsolePrinter

func print_results(results: TestResult) -> void:
	print("=".repeat(32) + "\nGodotUnit\n")
	
	for assertion in results.assertions:
		if not assertion.passed:
			print("[FAILED] %s" % [assertion.it])
			print(" ".repeat(9) + "Expected: %s" % [str(assertion.expected)])
			print(" ".repeat(9) + "Actual  : %s" % [str(assertion.actual)])
			print(" ".repeat(9) + "File: %s | Method: %s | Line: %d" % [
				assertion.source.file,
				assertion.source.function,
				assertion.source.line,
			])
			print("")
	
	print("TOTAL: %d | PASSED: %d" % [
		results.tests,
		results.passed,
	])
