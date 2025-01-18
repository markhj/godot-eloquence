extends Node

class_name DataSource

static var sources: Array[SQLite]

static func get_default() -> SQLite:
	assert(sources.size() > 0, "At least one SQLite source must be attached.")
	return sources[0]

static func add(sqlite: SQLite) -> void:
	sources.append(sqlite)
